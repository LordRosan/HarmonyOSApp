import { relationalStore } from "@kit.ArkData"

export class Device {
  number: string
  name: string
  type: DeviceType
  status: DeviceStatus
  failureRecords: FailureRecord[]
  repairRecords: RepairRecord[]
  selfCheckRecords: SelfCheckRecord[]

  constructor(
    number: string,
    name: string,
    type: DeviceType,
    status: DeviceStatus,
    failureRecords: FailureRecord[] = [],
    repairRecords: RepairRecord[] = [],
    selfCheckRecords: SelfCheckRecord[] = []
  ) {
    this.number = number
    this.name = name
    this.type = type
    this.status = status
    this.failureRecords = failureRecords
    this.repairRecords = repairRecords
    this.selfCheckRecords = selfCheckRecords
  }

  static resultSet(resultSet: relationalStore.ResultSet): Device {
    return new Device(
      resultSet.getString(resultSet.getColumnIndex('number')),
      resultSet.getString(resultSet.getColumnIndex('name')),
      resultSet.getString(resultSet.getColumnIndex('type')) as DeviceType,
      resultSet.getString(resultSet.getColumnIndex('status')) as DeviceStatus
    )
  }
}

export class FailureRecord {
  deviceNumber: string
  number: string
  date: string
  description: string
  emergency: EmergencyType
  operator: string

  constructor(
    deviceNumber: string,
    number: string,
    date: string,
    description: string,
    emergency: EmergencyType,
    operator: string
  ) {
    this.deviceNumber = deviceNumber
    this.number = number
    this.date = date
    this.description = description
    this.emergency = emergency
    this.operator = operator
  }
}

export class RepairRecord {
  deviceNumber: string
  number: string
  date: string
  type: RepairType
  description: string
  operator: string

  constructor(
    deviceNumber: string,
    number: string,
    date: string,
    type: RepairType,
    description: string,
    operator: string
  ) {
    this.deviceNumber = deviceNumber
    this.number = number
    this.date = date
    this.type = type
    this.description = description
    this.operator = operator
  }
}

export class SelfCheckRecord {
  deviceNumber: string
  number: string
  date: string
  passed: boolean

  constructor(
    deviceNumber: string,
    number: string,
    date: string,
    passed: boolean
  ) {
    this.deviceNumber = deviceNumber
    this.number = number
    this.date = date
    this.passed = passed
  }
}

export interface FailureRecordInput {
  deviceNumber: string
  date: string
  description: string
  emergency: EmergencyType
  operator: string
}

export interface RepairRecordInput {
  deviceNumber: string
  date: string
  type: RepairType
  description: string
  operator: string
}

export interface SelfCheckRecordInput {
  deviceNumber: string
  date: string
  passed: boolean
}

export interface FailureRecordIndices {
  device_number: number
  number: number
  date: number
  description: number
  emergency: number
  operator: number
}

export interface RepairRecordIndices {
  device_number: number
  number: number
  date: number
  type: number
  description: number
  operator: number
}

export interface SelfCheckRecordIndices {
  device_number: number
  number: number
  date: number
  passed: number
}

export enum DeviceType {
  SMALL = '小型设备',
  MEDIUM = '中型设备',
  LARGE = '大型设备'
}

export enum DeviceStatus {
  NORMAL = '正常',
  FAILURE = '故障'
}

export enum EmergencyType {
  BLUE = '蓝色等级-常规',
  YELLOW = '黄色等级-轻微',
  ORANGE = '橙色等级-中等',
  RED = '红色等级-严重'
}

export enum RepairType {
  RegularCheck = '常规检查',
  FailureRepair = '故障维修',
  UpdateAndUpgrade = '更新升级'
}

export interface RouteParam {
  deviceData: string
}