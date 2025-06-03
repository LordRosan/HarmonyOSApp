import { Rdb } from './Rdb'
import {
  Device,
  DeviceStatus,
  EmergencyType,
  FailureRecord,
  FailureRecordIndices,
  FailureRecordInput,
  RepairRecord,
  RepairRecordIndices,
  RepairRecordInput,
  RepairType,
  SelfCheckRecord,
  SelfCheckRecordInput,
  SelfCheckRecordIndices
} from './Device'
import { relationalStore } from '@kit.ArkData'
import promptAction from '@ohos.promptAction'

class DeviceAPI {
  private rdb: Rdb
  private deviceTable = 'devices'
  private failureTable = 'failure_records'
  private repairTable = 'repair_records'
  private selfCheckTable = 'self_check_records'

  constructor() {
    const deviceTableSql = `
      CREATE TABLE IF NOT EXISTS ${this.deviceTable} (
        number TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT CHECK(type IN ('小型设备', '中型设备', '大型设备')),
        status TEXT CHECK(status IN ('正常', '故障'))
      )`

    const failureTableSql = `
      CREATE TABLE IF NOT EXISTS ${this.failureTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_number TEXT REFERENCES ${this.deviceTable}(number),
        number TEXT,
        date TEXT,
        description TEXT,
        emergency TEXT,
        operator TEXT
      )`

    const repairTableSql = `
      CREATE TABLE IF NOT EXISTS ${this.repairTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_number TEXT REFERENCES ${this.deviceTable}(number),
        number TEXT,
        date TEXT,
        type TEXT,
        description TEXT,
        operator TEXT
      )`

    const selfCheckTableSql = `
      CREATE TABLE IF NOT EXISTS ${this.selfCheckTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_number TEXT REFERENCES ${this.deviceTable}(number),
        number TEXT,
        date TEXT,
        passed TEXT
      )`

    this.rdb = new Rdb(`${deviceTableSql};${failureTableSql};${repairTableSql};${selfCheckTableSql}`)
    this.initialize()

  }

  private async initialize(): Promise<void> {
    await this.rdb.getRdbStore()
    await this.createIndexes()
  }

  private async createIndexes(): Promise<void> {
    try {
      await this.rdb.rdbStore?.executeSql(
        'CREATE INDEX IF NOT EXISTS idx_failure_device ON failure_records(device_number)'
      )
      await this.rdb.rdbStore?.executeSql(
        'CREATE INDEX IF NOT EXISTS idx_repair_device ON repair_records(device_number)'
      )
      await this.rdb.rdbStore?.executeSql(
        `CREATE INDEX IF NOT EXISTS idx_selfcheck_device ON self_check_records(device_number)`
      )
    } catch (err) {
      console.error('创建索引失败: ', err)
    }
  }

  async deviceExists(number: string): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates(this.deviceTable)
    predicates.equalTo('number', number)

    try {
      const resultSet = await this.rdb.rdbStore?.query(predicates, ['number'])
      return resultSet ? resultSet.rowCount > 0 : false
    } catch (err) {
      console.error('查询设备存在性失败: ', err)
      return false
    }
  }

  async addDevice(device: Device): Promise<boolean> {
    if (await this.deviceExists(device.number)) {
      promptAction.showToast({ message: '设备已存在' })
      return false
    }

    const valueBucket: relationalStore.ValuesBucket = {
      'number': device.number,
      'name': device.name,
      'type': device.type,
      'status': device.status
    }

    try {
      await this.rdb.rdbStore?.insert(this.deviceTable, valueBucket)
      promptAction.showToast({ message: '添加设备成功' })
      return true
    } catch (err) {
      console.error('添加设备失败: ', err)
      promptAction.showToast({ message: '添加设备失败' })
      return false
    }
  }

  async getDevice(number: string): Promise<Device | null> {
    const predicates = new relationalStore.RdbPredicates(this.deviceTable)
    predicates.equalTo('number', number)

    try {
      const resultSet = await this.rdb.rdbStore?.query(predicates, ['*'])
      if (!resultSet || resultSet.rowCount === 0) {
        return null
      }

      resultSet.goToFirstRow()
      const device = Device.resultSet(resultSet)
      device.failureRecords = await this.getFailureRecords(number)
      device.repairRecords = await this.getRepairRecords(number)

      const isNumberValid = device.number.trim().length > 0
      const isNameValid = device.name.trim().length > 0
      const passed = isNumberValid && isNameValid

      const today = new Date().toISOString().slice(0, 10)
      await this.addSelfCheckRecord({
        deviceNumber: number,
        date: today,
        passed
      })
      device.selfCheckRecords = await this.getSelfCheckRecords(number)
      return device
    } catch (err) {
      console.error('查询设备失败: ', err)
      return null
    }
  }

  async updateDevice(device: Device): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates(this.deviceTable)
    predicates.equalTo('number', device.number)

    const valueBucket: relationalStore.ValuesBucket = {
      'name': device.name,
      'type': device.type,
      'status': device.status
    }

    try {
      const affectedRows = await this.rdb.rdbStore?.update(valueBucket, predicates)
      return affectedRows !== undefined && affectedRows > 0
    } catch (err) {
      console.error('更新设备失败: ', err)
      return false
    }
  }

  async deleteDevice(number: string): Promise<boolean> {
    return this.executeTransaction(async () => {

      await this.deleteRelatedRecords(number, this.failureTable)
      await this.deleteRelatedRecords(number, this.repairTable)
      await this.deleteRelatedRecords(number, this.selfCheckTable)

      const devicePredicates = new relationalStore.RdbPredicates(this.deviceTable)
      devicePredicates.equalTo('number', number)

      const affectedRows = await this.rdb.rdbStore?.delete(devicePredicates)
      return affectedRows !== undefined && affectedRows > 0
    })
  }

  private async deleteRelatedRecords(deviceNumber: string, table: string): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(table)
    predicates.equalTo('device_number', deviceNumber)

    try {
      await this.rdb.rdbStore?.delete(predicates)
    } catch (err) {
      console.error('删除记录失败: ', err)
    }
  }

  async addFailureRecord(record: FailureRecordInput): Promise<boolean> {
    return this.executeTransaction(async () => {
      const nextNumber = await this.getNextRecordNumber(record.deviceNumber, this.failureTable)
      const newRecord = new FailureRecord(
        record.deviceNumber,
        nextNumber.toString(),
        record.date,
        record.description,
        record.emergency,
        record.operator
      )

      const valueBucket: relationalStore.ValuesBucket = {
        'device_number': newRecord.deviceNumber,
        'number': newRecord.number,
        'date': newRecord.date,
        'description': newRecord.description,
        'emergency': newRecord.emergency,
        'operator': newRecord.operator
      }

      await this.rdb.rdbStore?.insert(this.failureTable, valueBucket)
      await this.updateDeviceStatus(newRecord.deviceNumber, DeviceStatus.FAILURE)
      return true
    })
  }

  async addRepairRecord(record: RepairRecordInput): Promise<boolean> {
    return this.executeTransaction(async () => {
      const nextNumber = await this.getNextRecordNumber(record.deviceNumber, this.repairTable)
      const newRecord = new RepairRecord(
        record.deviceNumber,
        nextNumber.toString(),
        record.date,
        record.type,
        record.description,
        record.operator
      )

      const valueBucket: relationalStore.ValuesBucket = {
        'device_number': newRecord.deviceNumber,
        'number': newRecord.number,
        'date': newRecord.date,
        'type': newRecord.type,
        'description': newRecord.description,
        'operator': newRecord.operator
      }

      await this.rdb.rdbStore?.insert(this.repairTable, valueBucket)
      await this.updateDeviceStatus(newRecord.deviceNumber, DeviceStatus.NORMAL)
      return true
    })
  }

  async addSelfCheckRecord(record: SelfCheckRecordInput): Promise<boolean> {
    return this.executeTransaction(async () => {
      const nextNumber = await this.getNextRecordNumber(record.deviceNumber, this.selfCheckTable)
      const newRecord = new SelfCheckRecord(
        record.deviceNumber,
        nextNumber.toString(),
        record.date,
        record.passed
      )
      const valueBucket: relationalStore.ValuesBucket = {
        'device_number': newRecord.deviceNumber,
        'number': newRecord.number,
        'date': newRecord.date,
        'passed': newRecord.passed ? '是' : '否'
      }

      await this.rdb.rdbStore?.insert(this.selfCheckTable, valueBucket)
      return true
    })
  }

  private async updateDeviceStatus(number: string, status: DeviceStatus): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(this.deviceTable)
    predicates.equalTo('number', number)

    const valueBucket: relationalStore.ValuesBucket = { 'status': status }

    try {
      await this.rdb.rdbStore?.update(valueBucket, predicates)
    } catch (err) {
      console.error('更新设备状态失败: ', err)
    }
  }

  private async getNextRecordNumber(deviceNumber: string, table: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(table)
    predicates.equalTo('device_number', deviceNumber)

    try {
      const resultSet = await this.rdb.rdbStore?.query(
        predicates,
        ['MAX(CAST(number AS INTEGER)) AS max_num']
      )

      if (resultSet && resultSet.rowCount > 0) {
        resultSet.goToFirstRow()
        const maxNum = resultSet.getDouble(resultSet.getColumnIndex('max_num'))
        return Number.isNaN(maxNum) ? 1 : maxNum + 1
      }
      return 1
    } catch (err) {
      console.error('获取下一个记录号失败: ', err)
      return 1
    }
  }

  private async getFailureRecords(deviceNumber: string): Promise<FailureRecord[]> {
    const predicates = new relationalStore.RdbPredicates(this.failureTable)
    predicates.equalTo('device_number', deviceNumber)

    try {
      const resultSet = await this.rdb.rdbStore?.query(predicates, [
        'device_number',
        'number',
        'date',
        'description',
        'emergency',
        'operator'
      ])
      return this.parseFailureResultSet(resultSet)
    } catch (err) {
      console.error('查询故障记录失败: ', err)
      return []
    }
  }

  private parseFailureResultSet(resultSet?: relationalStore.ResultSet): FailureRecord[] {
    const records: FailureRecord[] = []
    if (!resultSet || resultSet.rowCount === 0) {
      return records
    }

    const indices: FailureRecordIndices = {
      device_number: resultSet.getColumnIndex('device_number'),
      number: resultSet.getColumnIndex('number'),
      date: resultSet.getColumnIndex('date'),
      description: resultSet.getColumnIndex('description'),
      emergency: resultSet.getColumnIndex('emergency'),
      operator: resultSet.getColumnIndex('operator')
    }

    while (resultSet.goToNextRow()) {
      records.push(new FailureRecord(
        resultSet.getString(indices.device_number),
        resultSet.getString(indices.number),
        resultSet.getString(indices.date),
        resultSet.getString(indices.description),
        resultSet.getString(indices.emergency) as EmergencyType,
        resultSet.getString(indices.operator)
      ))
    }
    return records
  }

  private async getRepairRecords(deviceNumber: string): Promise<RepairRecord[]> {
    const predicates = new relationalStore.RdbPredicates(this.repairTable)
    predicates.equalTo('device_number', deviceNumber)

    try {
      const resultSet = await this.rdb.rdbStore?.query(predicates, [
        'device_number',
        'number',
        'date',
        'type',
        'description',
        'operator'
      ])
      return this.parseRepairResultSet(resultSet)
    } catch (err) {
      console.error('查询维修记录失败: ', err)
      return []
    }
  }

  private parseRepairResultSet(resultSet?: relationalStore.ResultSet): RepairRecord[] {
    const records: RepairRecord[] = []
    if (!resultSet || resultSet.rowCount === 0) {
      return records
    }

    const indices: RepairRecordIndices = {
      device_number: resultSet.getColumnIndex('device_number'),
      number: resultSet.getColumnIndex('number'),
      date: resultSet.getColumnIndex('date'),
      type: resultSet.getColumnIndex('type'),
      description: resultSet.getColumnIndex('description'),
      operator: resultSet.getColumnIndex('operator')
    }

    while (resultSet.goToNextRow()) {
      records.push(new RepairRecord(
        resultSet.getString(indices.device_number),
        resultSet.getString(indices.number),
        resultSet.getString(indices.date),
        resultSet.getString(indices.type) as RepairType,
        resultSet.getString(indices.description),
        resultSet.getString(indices.operator)
      ))
    }
    return records
  }

  private async getSelfCheckRecords(deviceNumber: string): Promise<SelfCheckRecord[]> {
    const predicates = new relationalStore.RdbPredicates(this.selfCheckTable)
    predicates.equalTo('device_number', deviceNumber)
    try {
      const resultSet = await this.rdb.rdbStore?.query(predicates, [
        'device_number',
        'number',
        'date',
        'passed'
      ])
      return this.parseSelfCheckResultSet(resultSet)
    } catch (err) {
      console.error('查询自检记录失败: ', err)
      return []
    }
  }

  private parseSelfCheckResultSet(resultSet?: relationalStore.ResultSet): SelfCheckRecord[] {
    const records: SelfCheckRecord[] = []
    if (!resultSet || resultSet.rowCount === 0) {
      return records
    }

    const indices: SelfCheckRecordIndices = {
      device_number: resultSet.getColumnIndex('device_number'),
      number: resultSet.getColumnIndex('number'),
      date: resultSet.getColumnIndex('date'),
      passed: resultSet.getColumnIndex('passed')
    }

    while (resultSet.goToNextRow()) {
      records.push(new SelfCheckRecord(
        resultSet.getString(indices.device_number),
        resultSet.getString(indices.number),
        resultSet.getString(indices.date),
        resultSet.getString(indices.passed) === '是'
      ))
    }
    return records
  }

  private async executeTransaction<T>(action: () => Promise<T>): Promise<T> {
    const store = this.rdb.rdbStore
    if (!store) {
      throw new Error("RDB store is not initialized")
    }

    try {
      store.beginTransaction()
      const result = await action()
      store.commit()
      return result
    } catch (error) {
      await store.rollback(await store.beginTrans())
      throw new Error(`Transaction failed: ${error instanceof Error ? error.message : String(error)}`)
    }
  }
}

export default new DeviceAPI()