<script setup lang="ts">
import * as gs3d from '@/utils/gs3d/index'
import { onMounted, ref, watch } from 'vue'
import kuangData from '@/static/kuang'
import { destination } from '@turf/turf';
let viewer: any
const { Cesium } = window
const { turf } = gs3d

let options = {
  height: 100.76, // 楼高
  floor: 5, // 楼层数
  lineColor: '#FFA500', // 边线色
  lineAlpha: 0.5,
  outlineShow: true, // 边线默认值
  fillClear: '#0000ff', // 填充色
  fillAlpha: 0.05, // 填充色透明度
  boxShow: true, // 填充默认值
  elevation: 0, // 高程
  geometries: [{ id: '', rectangle: [0, 0, 0, 0] }], // GEO信息 [{ id: String, rectangle:[west, south, east, north] }]
}

options.geometries = kuangData.map((geo) => {
  return {
    id: geo.geoNum4,
    rectangle: [geo.geoNumScope[1], geo.geoNumScope[0], geo.geoNumScope[3], geo.geoNumScope[2]],
  }
})

const polygon = {
  type: 'Feature',
  properties: {
    id: '7kuMolrTCYE',
    name: '7kuMolrTCYE',
  },
  geometry: {
    coordinates: [
      [
        [111.181279144793564, 31.363959102231885],
        [111.180659797649355, 31.363911025208314],
        [111.179758929075945, 31.364175448533619],
        [111.178942516931315, 31.363670639721651],
        [111.177929039786193, 31.363598523955773],
        [111.177112627641549, 31.363814871087428],
        [111.176070998353509, 31.36299755708858],
        [111.175113825494293, 31.362901402033284],
        [111.173649914062509, 31.363093712045515],
        [111.172749045489056, 31.363766793990077],
        [111.170834699770552, 31.366435035702661],
        [111.172157850487764, 31.368502269997485],
        [111.17255198048862, 31.369535870093689],
        [111.171932633344426, 31.36948779592268],
        [111.171763720486879, 31.370064684351714],
        [111.173368392633307, 31.373045218152502],
        [111.175029369065513, 31.373429796272905],
        [111.176690345497761, 31.373910516709948],
        [111.179195886217556, 31.373766300837065],
        [111.181391753365276, 31.3726606384581],
        [111.182405230510369, 31.371002120495923],
        [111.183869141942154, 31.369968536526137],
        [111.183418707655449, 31.369776240579867],
        [111.184432184800528, 31.366627338485408],
        [111.18451664122928, 31.365016790529037],
        [111.182095556938236, 31.364223525421934],
        [111.181279144793564, 31.363959102231885],
      ],
    ],
    type: 'Polygon',
  },
}

let show_reset_btn = ref(false)
let show_build_btn = ref(false)

onMounted(async () => {
  const defopt = {
    msaaSamples: 4,
    // terrain: Cesium.Terrain.fromWorldTerrain(),
  }
  viewer = gs3d.global.initViewer('mapContainer', defopt)
  // viewer.scene.globe.depthTestAgainstTerrain = true
  viewer.camera.setView({
    destination: Cesium.Cartesian3.fromDegrees(111.1748789388638, 31.154052261877535, 30000),
    orientation: {
      heading: Cesium.Math.toRadians(0),
      pitch: Cesium.Math.toRadians(-45),
      roll: 0.0
    }
  })
  addTerrain()
  addPolygon()
  addUnderGroundControler()

  // viewer.camera.moveEnd.addEventListener(flyingHandler)
  // gs3d.grid.buildGrid.draw(options, viewer)
  // addModel()

  // let handle = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas)
  // handle.setInputAction(async (e: any) => {
  //   let position = e.position
  //   let pick = viewer.scene.pick(position)
  //   console.log('click', pick)
  // }, Cesium.ScreenSpaceEventType.LEFT_CLICK)
})
//缩放到一定层级 清除背景开始建模
let flyingHandler = function () {
  viewer.camera.changed.addEventListener(async function () {
    // 获取当前相机高度
    let cameraHeight = viewer.camera.positionCartographic.height
    console.log('cameraHeight：', cameraHeight)
    let baseLayer = viewer.imageryLayers.get(0)
    if (cameraHeight > 30000 && baseLayer) {
      // viewer.scene.terrainProvider = new Cesium.EllipsoidTerrainProvider({});
      gs3d.grid.buildGrid.draw(options, viewer)
      baseLayer.alpha = 0
      show_reset_btn.value = true
      // viewer.imageryLayers.remove(viewer.imageryLayers.get(0));
    } else if (cameraHeight < 50000 && !baseLayer) {
      viewer.scene.setTerrain(new Cesium.Terrain(Cesium.CesiumTerrainProvider.fromIonAssetId(1)))
    }
  })
  viewer.camera.moveEnd.removeEventListener(flyingHandler)
}
let isUnderGround = ref(false)
const addUnderGroundControler = () => {
  viewer.camera.changed.addEventListener(async function () {
    // 获取当前相机高度
    let cameraHeight = viewer.camera.positionCartographic.height
    console.log('cameraHeight：', cameraHeight)
    if (cameraHeight < 25000) {
      isUnderGround.value = true
    } else {
      isUnderGround.value = false
    }
  })
}
watch(isUnderGround, (newVal) => {
  newVal ? enterUnderGround() : cancelUnderGround()
})
const addModel = () => {
  let position = Cesium.Cartesian3.fromDegrees(111.185279144793564, 31.373959102231885)
  const entity = viewer.entities.add({
    name: 'dem',
    position: position,
    // orientation:Cesium.Quaternion.fromHeadingPitchRoll(new Cesium.HeadingPitchRoll(Cesium.Math.toRadians(0), Cesium.Math.toRadians(0), Cesium.Math.toRadians(0))),
    model: {
      uri: '/src/assets/low_dem.gltf',
      // minimumPixelSize: 1000,
      // maximumScale: 220000,
      scale: 50000,
      heightReference: Cesium.HeightReference.CLAMP_TO_TERRAIN,
      imageBasedLightingFactor: new Cesium.Cartesian2(4, 1),
    },
  })
  const origin = entity.position.getValue()
  const heading = Cesium.Math.toRadians(45)
  const pitch = Cesium.Math.toRadians(0)
  const roll = Cesium.Math.toRadians(0)
  const hpr = new Cesium.HeadingPitchRoll(heading, pitch, roll)
  const orientation = Cesium.Transforms.headingPitchRollQuaternion(origin, hpr)
  entity.orientation = orientation
}

const addTerrain = () => {
  let options = {
    id: 'cesium_terrain',
    label: 'Cesium默认地形【cesium】',
    type: 'cesium_terrain',
    requestVertexNormals: true, //开启地形光照
    requestWaterMask: true // 开启水面波纹
  }
  gs3d.manager.layerManager.addLayer([options])
  // let options={
  //       id: 'modelLayer',
  //       label: 'TerrainGrid',
  //       type: 'cesium_terrain',
  //       url: '/dem',
  //       requestVertexNormals: true, //开启地形光照
  //       requestWaterMask: true, // 开启水面波纹
  //       terrainExaggeration:100000,
  //       terrainExaggerationRelativeHeight:1000
  //     }
  // gs3d.manager.layerManager.addLayer([options])

  // let terrainProvider = Cesium.CesiumTerrainProvider.fromUrl('/dem')
  // viewer.terrainProvider = terrainProvider
  // //用于夸大地形的标量。默认为1.0（不夸张）。值2.0将地形缩放 2 倍。的值0.0使地形完全平坦。请注意，地形夸大不会修改任何其他图元，因为它们是相对于椭圆体定位的。
  // viewer.scene.globe.terrainExaggeration = 4
  // //夸大地形的高度。默认为0.0（相对于椭球表面缩放）。高于此高度的地形将向上缩放，低于此高度的地形将向下缩放。请注意，地形夸大不会修改任何其他图元，因为它们是相对于椭圆体定位的。如果Globe#terrainExaggeration是1.0这个值将没有效果。
  // viewer.scene.globe.terrainExaggerationRelativeHeight = 1.0



}

const removeTerrain = () => {
  gs3d.manager.layerManager.removeLayer({ id: 'cesium_terrain' })

}
const addPolygon = () => {
  let optionPolygon = {
    graphicName: '',
    showBillBoard: false,
    clampToGround: true,
    entityProperties: {},
  }
  let entity = gs3d.common.draw.drawGraphic(viewer, polygon.geometry, optionPolygon)
  // gs3d.common.position.locationEntity(viewer, entity)
}

const drawTerrainGrid = () => {
  let gridOptions = {
    lineColor: "#FFFF00",
    lineAlpha: 0.75,
    lineWidth: 1,
    fillClear: "#FF0000",
    fillAlpha: 0.05,
    clampToGround: false,
    elevation: 0,
    features: [],
    height: 1,
    name: ''
  }
  getTerrainHeight(kuangData, (features: any) => {
    gridOptions.features = features
    if (!features?.length) {
      console.log('未查找到模型数据，请尝试重新绘制或选择其他层级')

      return
    }
    drawModelGrid(gridOptions)
  })
}
let featuresData: Array<any> = []
const getTerrainHeight = (_positions: any, callback: any) => {
  let cartesians: any = []
  featuresData = []
  let features: any = _positions.map((geo: any) => {
    const line = turf.lineString([
      [geo.geoNumScope[1], geo.geoNumScope[0]],
      [geo.geoNumScope[3], geo.geoNumScope[2]],
    ])
    const bbox = turf.bbox(line)
    const feature = turf.bboxPolygon(bbox, { properties: { id: geo.geoNum4, bbox: bbox } })
    const centroid = turf.centroid(feature)
    let center = turf.getCoord(centroid)
    feature.properties['center'] = center
    cartesians.push(Cesium.Cartographic.fromDegrees(center[0], center[1], 0))
    return feature
  })

  Cesium.sampleTerrainMostDetailed(viewer.terrainProvider, cartesians).then((clampedCartesians: any) => {
    if (clampedCartesians.length) {
      let heightArray: Array<any> = []
      clampedCartesians.forEach((item: any) => {
        item && heightArray.push(item.height)
      })
      let min = Math.min(...heightArray)

      clampedCartesians.map((item: any, n: any) => {
        if (item) {
          let feature: any = features[n]
          let height = item.height
          feature.properties.height = min
          feature.properties.extruded = height < min ? 0 : height - min
          height >= min && featuresData.push(feature)
        }
      })
    }
    callback(featuresData)
  })
}
let rectangleGrid: any = null
const drawModelGrid = (gridOptions: any) => {
  if (!rectangleGrid) {
    rectangleGrid = new gs3d.grid.rectangleGrid(viewer)
  }
  rectangleGrid.draw(gridOptions)
}
const clearModelGrid = () => {
  rectangleGrid && rectangleGrid.destroy()
}
const enterUnderGround = () => {
  const { scene } = viewer
  const { globe } = viewer.scene
  const { imageryLayers } = viewer
  scene.globe.depthTestAgainstTerrain = false
  scene.screenSpaceCameraController.inertiaZoom = 0.5 //调整相机惯性缩放时长
  scene.screenSpaceCameraController.enableCollisionDetection = false //禁用相机与地形的碰撞检测
  // scene.highDynamicRange = false //关闭高动态范围渲染
  // scene.skyAtmosphere.show = false //关闭大气
  // scene.skyBox.show = false //关闭天空盒
  // scene.fog.enabled = false //关闭雾
  // globe.baseColor = Cesium.Color.BLACK
  globe.baseColor = Cesium.Color.TRANSPARENT
  if (imageryLayers && imageryLayers.length > 0) {
    // 遍历所有的影像，把影像透明度调整为0.7
    for (let index = 0; index < imageryLayers.length; index++) {
      const layer = imageryLayers.get(index)
      layer.alpha = 0.2
    }
  }
  //当相机在地下或地球是半透明时渲染地球背面的颜色，根据相机的距离与地球颜色混合。
  globe.undergroundColor = Cesium.Color.BLACK
  // globe.undergroundColor = Cesium.Color.TRANSPARENT
  //获取或设置 Globe#undergroundColor 与地球颜色混合的近距离和远距离
  globe.undergroundColorAlphaByDistance.near = 1000
  globe.undergroundColorAlphaByDistance.far = 1000000
  globe.undergroundColorAlphaByDistance.nearValue = 0
  globe.undergroundColorAlphaByDistance.farValue = 1
  removeTerrain()

}
const cancelUnderGround = () => {
  const { scene } = viewer
  const { globe } = viewer.scene
  const { imageryLayers } = viewer
  scene.globe.depthTestAgainstTerrain = true

  // 退出地下模式的参数---------------------------------------------------
  const originalOpts = {
    baseColor: globe.baseColor,
    alpha: 1.0,
    skyBox: true,
    skyAtmosphere: true,
    highDynamicRange: true,
    fog: true
  }
  //启用或禁用相机与地形的碰撞检测
  scene.screenSpaceCameraController.enableCollisionDetection = true
  scene.highDynamicRange = originalOpts.highDynamicRange
  scene.skyAtmosphere.show = originalOpts.skyAtmosphere
  scene.skyBox.show = originalOpts.skyBox
  scene.fog.enabled = originalOpts.fog
  globe.baseColor - originalOpts.baseColor
  if (imageryLayers && imageryLayers.length > 0) {
    // 遍历所有的影像，把影像透明度调整回来
    for (let index = 0; index < imageryLayers.length; index++) {
      const layer = imageryLayers.get(index)
      layer.alpha = 1
    }
  }
}

let showBox = ref(false)
const showInformation = () => {
  showBox.value = true
}

const reset = () => {
  let baseLayer = viewer.imageryLayers.get(0)
  baseLayer.alpha = 50
}
</script>

<template>
  <div id="mapContainer"></div>
  <div class="active-btn">
    <el-button v-show="show_reset_btn" @click="reset">重置</el-button>
    <el-button @click="drawTerrainGrid">构建矿山网格模型</el-button>
    <el-button id="fill-show-hidden" @click="gs3d.grid.buildGrid.changeBoxShow()">填充显/隐</el-button>
    <el-button id="border-show-hidden" @click="gs3d.grid.buildGrid.changeOutlineShow()">边框显/隐</el-button>
    <el-upload class="upload-demo" action="#" :show-file-list="false" style="display: inline-block; margin-left: 10px"
      @change="showInformation">
      <el-button>信息导入</el-button>
    </el-upload>
  </div>
  <div id="information-box" v-show="showBox">
    <span class="title">爆破信息</span>
    <div class="details">
      <ul>
        <li>负责人：王阳</li>
        <li>爆破长度：100米</li>
        <li>爆破区域：如图</li>
        <li>
          操作流程：
          <ul class="process">
            <li>安全阀门已关闭</li>
            <li>人员疏散完毕</li>
            <li>感知设备正常</li>
            <li>炸药投放位置已确认</li>
          </ul>
        </li>
      </ul>
    </div>
    <div class="operate"><el-button type="primary" @click="showBox = false">关闭</el-button></div>
  </div>
</template>

<style scoped lang="scss">
#mapContainer {
  height: 100vh;
  width: 100vw;
}

.active-btn {
  top: 20px;
  left: 50px;
  z-index: 9;
  position: fixed;
}

#information-box {
  color: white;
  width: 350px;
  height: 500px;
  background-image: url(assets/border-top-right.webp);
  background-size: 100% 100%;
  position: fixed;
  top: 50px;
  right: 50px;
  z-index: 9;
  font-weight: 500;

  .title {
    font-size: 20px;
    position: relative;
    top: 3px;
    left: 45px;
  }

  .details {
    ul {
      list-style-type: none;

      li {
        margin-bottom: 10px;
      }
    }

    .process {
      margin-top: 10px;
      color: rgb(130 239 151);
      font-weight: 900;
      font-size: 18px;

      li:before {
        content: '✓';
      }

      li {
        margin-bottom: 16px;
      }
    }
  }

  .operate {
    text-align: center;
    margin-top: 40px;
  }
}
</style>
