<template>
  <div class="dashboard-container">
    <div class="header">
      <div class="title">
        <h1>北斗网格码智慧矿山系统</h1>
      </div>
    </div>

    <div class="content">
      <el-row :gutter="20" style="height: 60%;">
        <el-col :span="14" style="height: 100%;">
          <el-row style="height: calc(50% - 7px);">
            <el-col :span="24" style="height: 100%;">
              <div class="item service">
                <span class="title">服务器</span>
                <div class="content-box">
                  <div class="left">
                    <div class="status internet">
                      <p class="text">网络连接</p>
                      <p class="status-text">正常</p>
                    </div>
                    <div class="status cpu">
                      <p class="text">CPU温度</p>
                      <p class="status-text">52°C/125°F</p>
                    </div>
                  </div>
                  <div class="right">
                    <div style="position: relative;">
                      <el-progress type="circle" :percentage="serviceData.cpu" :color="progressColor(serviceData.cpu)"
                        :show-text="false" :stroke-width="15" style="margin-right: 50px;"></el-progress>
                      <div class="circleText">CPU<br /> <span style="font-size: 24px;">{{ serviceData.cpu
                          }}</span>%</div>
                    </div>
                    <div style="position: relative;"><el-progress type="circle" :percentage="serviceData.memory"
                        :color="progressColor(serviceData.memory)" :stroke-width="15" :show-text="false"
                        style="margin-right: 50px;"></el-progress>
                      <div class="circleText">内存<br /> <span style="font-size: 24px;">{{ serviceData.memory
                          }}</span>%</div>
                    </div>
                    <div style="position: relative;"><el-progress type="circle" :percentage="serviceData.disk"
                        :color="progressColor(serviceData.disk)" :show-text="false" :stroke-width="15"></el-progress>
                      <div class="circleText">硬盘<br /> <span style="font-size: 24px;">{{ serviceData.disk
                          }}</span>%</div>
                    </div>

                  </div>
                </div>
              </div>
            </el-col>
          </el-row>
          <el-row :gutter="20" style="height: calc(50% - 8px);margin-top: 15px;">
            <el-col :span="12" style="height: 100%;">
              <div class="item center-mini">
                <span class="title">电存储</span>
                <div class="content-box-2">
                  <div class="top">
                    <div class="status internet">
                      <span class="text">网络连接</span>
                      <span class="status-text">正常</span>
                    </div>
                    <div class="status cpu">
                      <span class="text">CPU温度</span>
                      <span class="status-text">52°C/125°F</span>
                    </div>
                  </div>
                  <div class="bottom">
                    <div style="position: relative;">
                      <el-progress type="circle" :percentage="DStorage.cpu" :color="progressColor(DStorage.cpu)"
                        :show-text="false" :stroke-width="12" :width="100"></el-progress>
                      <div class="circleText">CPU<br /> <span style="font-size: 18px;">{{ DStorage.cpu
                          }}</span>%</div>
                    </div>
                    <div style="position: relative;"><el-progress type="circle" :percentage="DStorage.memory"
                        :color="progressColor(DStorage.memory)" :stroke-width="12" :show-text="false"
                        :width="100"></el-progress>
                      <div class="circleText">内存<br /> <span style="font-size: 18px;">{{ DStorage.memory
                          }}</span>%</div>
                    </div>
                    <div style="position: relative;"><el-progress type="circle" :percentage="DStorage.disk"
                        :color="progressColor(DStorage.disk)" :show-text="false" :stroke-width="12"
                        :width="100"></el-progress>
                      <div class="circleText">硬盘<br /> <span style="font-size: 18px;">{{ DStorage.disk
                          }}</span>%</div>
                    </div>
                  </div>
                </div>
              </div>
            </el-col>
            <el-col :span="12" style="height: 100%;">
              <div class="item center-mini">
                <span class="title">光存储</span>
                <div class="content-box-2">
                  <div class="top">
                    <div class="status internet">
                      <span class="text">网络连接</span>
                      <span class="status-text">正常</span>
                    </div>
                    <div class="status cpu">
                      <span class="text">CPU温度</span>
                      <span class="status-text">52°C/125°F</span>
                    </div>
                  </div>
                  <div class="bottom">
                    <div style="position: relative;">
                      <el-progress type="circle" :percentage="GStorage.cpu" :color="progressColor(GStorage.cpu)"
                        :show-text="false" :stroke-width="12" :width="100"></el-progress>
                      <div class="circleText">CPU<br /> <span style="font-size: 18px;">{{ GStorage.cpu
                          }}</span>%</div>
                    </div>
                    <div style="position: relative;"><el-progress type="circle" :percentage="GStorage.memory"
                        :color="progressColor(GStorage.memory)" :stroke-width="12" :show-text="false"
                        :width="100"></el-progress>
                      <div class="circleText">内存<br /> <span style="font-size: 18px;">{{ GStorage.memory
                          }}</span>%</div>
                    </div>
                    <div style="position: relative;"><el-progress type="circle" :percentage="GStorage.disk"
                        :color="progressColor(GStorage.disk)" :show-text="false" :stroke-width="12"
                        :width="100"></el-progress>
                      <div class="circleText">硬盘<br /> <span style="font-size: 18px;">{{ GStorage.disk
                          }}</span>%</div>
                    </div>

                  </div>
                </div>
              </div>
            </el-col>
          </el-row>
        </el-col>
        <!-- 分类存储 -->
        <el-col :span="10" style="height: 100%;">
          <div class="item type-container">
            <span class="title">设备分类</span>
            <div class="chart-box" style="height: calc(100% - 5px)">
              <div id="tab-pie" style="height: 80%;width: 100%;" />
            </div>

          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" style="flex: 1;margin-top: 15px;">
        <el-col :span="14" style="height: 100%;">
          <div class="item service">
            <div class="head-container">
              <div><span class="title">巡检记录</span></div>
            </div>
            <el-table :data="recordTableData" border style="width: 90%;margin:50px auto;"
              :header-cell-style="{ background: '#11408E' }" :row-style="rowStyle">
              <el-table-column label="异常设备" width="180" prop="name" />
              <el-table-column label="设备状态" prop="status" />
              <el-table-column prop="location" label="巡检位置" />
              <el-table-column prop="recordName" label="处理人" />
              <el-table-column prop="recordTime" label="巡检时间" />
            </el-table>
          </div>
        </el-col>
        <el-col :span="10" style="height: 100%;">
          <div class="item catalogue-container">
            <div class="head-container"><span class="title">历史记录</span></div>
            <div id="catalogue" style="height: calc(100% - 48px);width: 100%;" />
          </div>

        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup lang="ts">
import * as echarts from 'echarts';
import { onMounted, reactive, ref } from 'vue'
const serviceData = {
  cpu: 15,
  memory: 78,
  disk: 43
}
const DStorage = {
  cpu: 55,
  memory: 23,
  disk: 100
}
const GStorage = {
  cpu: 1,
  memory: 4,
  disk: 8
}
let catalogueChart = ref()
let catalogueOption = reactive({
  xAxis: {
    type: 'category',
    data: ['4月11日', '4月12日', '4月13日', '4月14日', '4月15日', '4月16日', '4月17日'],
    axisLine: {
      lineStyle: {
        color: '#fff'
      }
    }
  },
  yAxis: {
    type: 'value',
    axisLine: {
      lineStyle: {
        color: '#fff'
      }
    }
  },
  series: [
    {
      data: [150, 230, 224, 218, 135, 147, 260],
      type: 'line'
    },
    {
      data: [120, 130, 124, 118, 35, 47, 160],
      type: 'line'
    }
  ]
})

let catalogueListOption = ref([])
let catalogueVisible = ref(false)
const recordTableData = [{
  name: '环境监控',
  status: '异常',
  location: '北二门Q4',
  recordName: '王阳',
  recordTime: '2024年2月12日'
}, {
  name: '摄像头',
  status: '异常',
  location: '矿洞入口处',
  recordName: '王阳',
  recordTime: '2024年4月2日'
}, {
  name: '局扇',
  status: '异常',
  location: '南三门',
  recordName: '王阳',
  recordTime: '2024年3月21日'
}]

let tabPieChart = ref()
const tabPieQuery = reactive({
  abscissa: 'fl_id',
  startYear: `${(new Date()).getFullYear()}`,
  endYear: `${(new Date()).getFullYear()}`,
  csId: null,
  ywId: null,
  flId: null,
  zlId: null,
  jbId: null,
  lxId: null
})

const startDateOpt = {
  disabledDate: (time: Date) => {
    return time.getFullYear() > (Number(tabPieQuery.endYear) ? Number(tabPieQuery.endYear) : (new Date()).getFullYear()) || time.getFullYear() > (new Date()).getFullYear()
  },
}

const endDateOpt = {
  disabledDate: (time: Date) => {
    return time.getFullYear() < Number(tabPieQuery.startYear) || time.getFullYear() > (new Date()).getFullYear()
  },
}
let visible = ref(false)

const tabPieOption = reactive({
  tooltip: {
    trigger: 'item',
    formatter: '{b}: {c} 个'
  },
  legend: {
    bottom: '0',
    left: 'center',
    textStyle: {
      color: '#fff'
    },
    icon: 'circle'
  },
  series: [
    {
      type: 'pie',
      data:
        [{ value: 1048, name: '硐室' },
        { value: 735, name: '摄像头' },
        { value: 580, name: '局扇' },
        { value: 484, name: '闸门' },
        { value: 300, name: '环境监测' }],
      radius: ['20%', '50%'],
      label: {
        formatter: '{b}: {d}%',
        color: '#fff'
      }
    }
  ]
})

onMounted(() => {
  catalogueChart.value = echarts.init(document.getElementById('catalogue'));
  // 分类pieChart初始化
  catalogueChart.value.setOption(catalogueOption);
  tabPieChart.value = echarts.init(document.getElementById('tab-pie'));
  tabPieChart.value.setOption(tabPieOption);
  // 自适应
  window.addEventListener('resize', () => {
    catalogueChart.value.resize()
    tabPieChart.value.resize()
  })
})

const progressColor = (value: number) => {
  if (value <= 30) {
    return '#36BDAF'
  } else if (30 < value && value <= 60) {
    return '#DF7A4D'
  } else if (60 < value && value <= 80) {
    return '#D75656'
  } else if (80 < value && value <= 100) {
    return '#C25868'
  }
}
const rowStyle = ({ rowIndex }: { rowIndex: number }) => {
  if (rowIndex % 2 === 0) {
    return { "background": "#062456" };
  } else {
    return { 'background': '#092D68' };
  }
}
</script>

<style lang="scss" scoped>
:deep(.el-table) {

  tr,
  td {
    color: white;
  }

  td,
  th.is-leaf {
    border-bottom: 1px solid #06488C;
  }
}



:deep(.el-table--border) {

  td,
  th {
    border-right: transparent;
  }
}

.dashboard {
  &-container {
    width: 100vw;
    height: 100vh;
    background-color: #0a1462;
    overflow-y: auto;

    .header {
      display: flex;
      justify-content: space-between;
      /* align-items: center; */
      padding: 0 20px;
      position: relative;
      height: 100px;
      background-image: url(@/assets/header-bg.webp);
      background-size: 100% 100%;

      .title {
        flex: 1;
        text-align: center;

        h1 {
          margin: 0;
          font-size: 1.4vw;
          line-height: 60px;
          display: inline-block;
          width: 600px;
          max-width: 30vw;
          color: #fff;
          /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
        }
      }
    }

    .content {
      height: calc(100% - 100px);
      min-height: 850px;
      display: flex;
      flex-direction: column;
      padding: 0 20px 20px;

      .service {
        background-image: url(@/assets/border-top-left.webp);
        background-size: 100% 100%;

        .title {
          color: #fff
        }

        .content-box {
          display: flex;
          justify-content: space-around;
          align-items: center;
          position: relative;
          top: 20px;

          @media (max-height: 1000px) {
            height: calc(850px * 0.3 - 73px);
          }

          .left {
            display: flex;
            flex-direction: column;

            .status {
              width: 21.4vh;
              height: 7.2vh;

              @media (max-height: 1000px) {
                width: 29vh;
                height: 9vh;
              }

              background-size: 100% 100%;
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;

              .text {
                font-size: 14px;
                line-height: 20px;
                margin: 0;
                color: #fff;
              }

              .status-text {
                margin: 0;
                font-weight: bold;
                line-height: 20px;
              }
            }

            .cpu {
              background-image: url(@/assets/cpu_1.webp);
              color: #fbd632;
            }



            .internet {
              background-image: url(@/assets/internet_1.webp);

              .status-text {
                color: #30FEE8;
              }
            }
          }

          .right {
            display: flex;

            .circleText {
              min-width: 76px;
              text-align: center;
              width: fit-content;
              position: absolute;
              bottom: 44px;
              left: 28px;
              color: #fff;
            }

            :deep(.el-progress-circle) {
              svg path:first-child {
                stroke: #14368f;
              }
            }
          }
        }
      }

      .type-container {
        background-image: url(@/assets/border-top-right.webp);
        background-size: 100% 100%;

        .title {
          color: #fff;
        }
      }

      .center-mini {
        background-image: url(@/assets/border-center-mini.jpg);
        background-size: 100% 100%;

        .title {
          color: #fff
        }

        .content-box-2 {
          display: flex;
          flex-direction: column;
          justify-content: space-around;
          align-items: center;
          position: relative;
          top: 20px;

          @media (max-height: 1000px) {
            height: calc(850px * 0.3 - 73px);
          }

          .top {
            width: 80%;
            display: flex;
            justify-content: center;



            .status {
              width: 21vh;
              height: 5.5vh;
              display: inline-block;
              display: inline-flex;
              align-items: center;
              justify-content: center;



              background-size: 100% 100%;


              .text {
                font-size: 1.3vh;
                margin: 0 1vh 0 0px;
                min-width: 41px;
                color: #fff;
                // @media (max-height: 1000px) {
                //   font-size: 10px;
                //   margin: 0 0 0 35px;
                // }
              }

              .status-text {
                margin: 0;
                font-weight: bold;
                line-height: 20px;

                // @media (max-height: 1000px) {
                //   font-size: 12px;
                //   margin-left: 10px;
                // }
                font-size: 1.5vh;
              }
            }

            .cpu {
              background-image: url(@/assets/cpu_2.jpg);

              .text {
                margin-left: 5vh;
              }

              .status-text {
                color: #fbd632;
              }
            }

            .internet {
              background-image: url(@/assets/internet_2.jpg);

              .status-text {
                color: #30FEE8;
              }
            }
          }

          .bottom {
            display: flex;
            justify-content: space-around;
            width: 100%;
            padding: 0 20px;

            .circleText {
              text-align: center;
              width: fit-content;
              position: absolute;
              bottom: 34px;
              left: 22px;
              min-width: 61px;
              color: #fff;

              @media (max-height: 1000px) {
                font-size: 12px;
                bottom: 27px;
                left: 10px;

              }
            }

            :deep(.el-progress-circle) {
              /* margin-right: 50px; */

              @media (max-height: 1000px) {
                /* margin-right: 20px; */
                height: 80px !important;
                width: 80px !important;
              }

              svg path:first-child {
                stroke: #14368f;
              }
            }
          }
        }
      }

      .catalogue-container {
        background-image: url(@/assets/border-bottom-right.webp);
        background-size: 100% 100%;
      }

      .item {
        width: 100%;
        height: 100%;
        background-color: #0f2281;
        color: #fff;

        .title {
          font-size: 20px;
          font-weight: 500;
          position: relative;
          left: 3vw;
        }

        .head-container {
          padding: 8px;

          @media (max-width: 1600px) {
            padding: 7px;
          }

          display: flex;
          justify-content: space-between;
          align-items: center;



          .title {
            font-size: 20px;
            font-weight: 700;
            margin-right: 20px;

            @media (min-width: 1600px) {
              top: 3px;
            }
          }
        }

      }
    }
  }
}
</style>

<style lang="scss">
.el-popover {
  background-color: #063078;
  opacity: 1;
  color: #fff;
  border: 1px solid #10569E;

  .el-popover__title {
    color: #fff;
  }
}

.type-popper {
  background-color: #063078;
  opacity: 1;
  border: 1px solid #10569E;

  .el-select-dropdown__item {
    color: #7BC9FF;
  }

  .el-select-dropdown__item.selected {
    color: #fff;
    font-weight: 700;
  }

  .el-select-dropdown__item.hover,
  .el-select-dropdown__item:hover {
    background-color: #0F4196;
  }
}

.filter-popper {
  .el-form {
    .el-form-item__label {
      color: #fff;
    }

    .el-form-item__content {
      .el-input__inner {
        background-color: #082B67;
        border: 1px solid #1E4C9C;
        color: #fff;
      }
    }

    .el-date-editor--year {
      .el-input__inner {
        padding-left: 22px;
        padding-right: 0;
      }

      .el-input__prefix {
        left: 0
      }

      .el-input__suffix {
        right: 2px;
      }
    }
  }
}

.catalogue-popper {
  height: 250px;

  .el-tree {
    background-color: #063078;
    color: #fff;
    height: 75%;
    overflow: auto;

    .el-tree-node__content:hover {
      background-color: transparent;
    }

    .el-tree-node.is-current>.el-tree-node__content {
      background-color: transparent;
    }

    .el-tree-node:focus>.el-tree-node__content {
      background-color: transparent;
    }

    .el-checkbox__inner {
      background-color: transparent;
      border: 1px solid #3B7BED;
    }

    .is-checked {
      .el-checkbox__inner {
        background-color: #3B7BED;
      }
    }
  }
}
</style>
