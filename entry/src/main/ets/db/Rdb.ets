import { relationalStore } from '@kit.ArkData'

export class Rdb {
  rdbStore: relationalStore.RdbStore | null = null
  private sqlCreateTable: string = ''
  private STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'device.db',
    securityLevel: relationalStore.SecurityLevel.S1
  }

  constructor(sqlCreateTable: string) {
    this.sqlCreateTable = sqlCreateTable
  }

  async getRdbStore() {
    if (this.rdbStore != null) {
      return
    }

    try {
      this.rdbStore = await relationalStore.getRdbStore(getContext(), this.STORE_CONFIG)
      await this.rdbStore.executeSql('PRAGMA foreign_keys = ON;')
      const statements = this.sqlCreateTable.split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0)
      for (const sql of statements) {
        await this.rdbStore.executeSql(sql)
      }
    } catch (err) {
      console.error('RDB初始化失败: ', err)
    }
  }
}