<script setup lang="ts">
import * as gs3d from '@/utils/gs3d/index'
import { onMounted, reactive, ref, watch } from 'vue'
import kuangData from '@/static/kuang'
import layerControlOptions from '@/static/layerControlOptions'
import { tubeJson } from '@/static/line'
import suiDaoJson from '@/static/suiDao'
import deviceJson from '@/static/device'

let viewer: any
const { Cesium } = window
const { turf } = gs3d

const polygon = {
  type: 'Feature',
  properties: {
    id: '7kuMolrTCYE',
    name: '7kuMolrTCYE',
  },
  geometry: {
    coordinates: kuangData.scope,
    type: 'Polygon',
  },
}
const show_layer_control_box = ref(false)
onMounted(async () => {
  const defopt = {
    msaaSamples: 4,
    // terrain: Cesium.Terrain.fromWorldTerrain(),
  }
  viewer = gs3d.global.initViewer('mapContainer', defopt)
  // viewer.scene.globe.depthTestAgainstTerrain = true
  viewer.camera.setView({
    destination: Cesium.Cartesian3.fromDegrees(111.16281750317003, 31.302816199976156, 3000),
    orientation: {
      heading: Cesium.Math.toRadians(11.4455466194539870),
      pitch: Cesium.Math.toRadians(-14.695843893488675),
      roll: 0.0
    }
  })
  addTerrain()
  addUnderGroundControler()
})

let hasTerrainGrid = ref(false)
let isUnderGround = ref(false)
const addUnderGroundControler = () => {
  viewer.camera.changed.addEventListener(async function () {
    // 获取当前相机高度
    let cameraHeight = viewer.camera.positionCartographic.height
    // console.log('cameraHeight：', cameraHeight)

    if (cameraHeight < 3000) {
      if (!hasTerrainGrid.value) {
        drawTerrainGrid()
        show_layer_control_box.value = true
        openPick()
      }
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
const openPick = () => {
  let gridOptions = {
    lineColor: "#FFFF00",
    lineAlpha: 0.75,
    lineWidth: 1,
    fillClear: "#FF0000",
    fillAlpha: 1,
    clampToGround: false,
    elevation: 0,
    features: [] as Array<any>,
    height: 1,
    name: ''
  }
  let pickGrid = new gs3d.grid.rectangleGrid(viewer)
  let handle = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas)
  handle.setInputAction(async (e: any) => {
    let position = e.position
    let pick = viewer.scene.drillPick(position)
    let targetPrimitiveArray = pick.filter((item: any) => { return typeof (item.id) == 'string' && item.id.includes('device') });

    let deviceId = null
    let idArray: Array<any> = []
    targetPrimitiveArray.forEach((item: any) => {
      idArray.push(item.id)
    })
    idArray = Array.from(new Set(idArray))
    console.log('idArray', idArray);

    let idArray2 = idArray.filter((item: any) => {
      return !item.includes("suidao")
    })
    if (idArray2.length > 0) {
      deviceId = idArray2[0]
    } else {
      deviceId = idArray.find((item: any) => {
        return item.includes("suidao")
      })
    }
    console.log('deviceId', deviceId)

    if (deviceId) {
      let targetPrimitive = targetPrimitiveArray.find((item: any) => {
        return item.id == deviceId
      })
      let targetInstance = targetPrimitive.primitive.geometryInstances.find((item: any) => { return item.id == targetPrimitive.id });
      // console.log('targetInstance', targetInstance);
      gridOptions.features = [targetInstance.feature]
      pickGrid.draw(gridOptions)
    }
  }, Cesium.ScreenSpaceEventType.LEFT_CLICK)
}

const addTerrain = () => {
  // let options = {
  //   id: 'cesium_terrain',
  //   label: 'Cesium默认地形【cesium】',
  //   type: 'cesium_terrain',
  //   requestVertexNormals: true, //开启地形光照
  //   requestWaterMask: true // 开启水面波纹
  // }
  // gs3d.manager.layerManager.addLayer([options])
  let options = {
    id: 'modelLayer',
    label: 'TerrainGrid',
    type: 'cesium_terrain',
    url: 'demTerrain',
    requestVertexNormals: true, //开启地形光照
    requestWaterMask: true, // 开启水面波纹
    // terrainExaggeration:1,
    // terrainExaggerationRelativeHeight:1000
  }
  gs3d.manager.layerManager.addLayer([options])
}
const removeTerrain = () => {
  gs3d.manager.layerManager.removeLayer({ id: 'cesium_terrain' })
}

let entityWall: any = null
const addPolygon = async () => {
  gs3d.effect.breath.draw(viewer, polygon.geometry, {
    clampToGround: true,
    color: "#ff0000",
    fill: true,
  })

  entityWall = await addWall(polygon.geometry, {
    graphicName: "basePolygon",
    width: 1,
    color: "#FFDE59",
    // color: "#FF0000",
    wallOption: {
      maximumHeights: 500,
      minimumHeights: 0,
      clampToGround: true
    },
  })
}
const removePolygon = () => {
  removeWall()
  gs3d.effect.breath.clear()
}
const addWall = async (geometry: any, option: any) => {
  let { maximumHeights, minimumHeights, clampToGround } = option.wallOption || {}
  let coordinates: Array<any> = []
  let length = geometry.coordinates[0].length
  let maximumHeight: Array<any> = new Array(length).fill(maximumHeights || 50)
  let minimumHeight: Array<any> = new Array(length).fill(minimumHeights || 0)
  var rgba = option.color ? Cesium.Color.fromCssColorString(option.color) : Cesium.Color.fromCssColorString('#00FF33')

  let cartesians: Array<any> = []
  geometry.coordinates.forEach((item: Array<any>) => {
    item.forEach((coord: Array<any>) => {
      cartesians.push(Cesium.Cartographic.fromDegrees(coord[0], coord[1], 0))
      coord.forEach((i: number) => {
        coordinates.push(i)
      })
    })
  })

  if (clampToGround) {
    maximumHeight = [];
    minimumHeight = [];
    let clampedCartesians = await Cesium.sampleTerrainMostDetailed(viewer.terrainProvider, cartesians);
    if (clampedCartesians.length) {
      clampedCartesians.forEach((item: any) => {
        item && minimumHeight.push(item.height + minimumHeights);
        item && maximumHeight.push(item.height + maximumHeights);
      });
    }
  }

  var entity = viewer.entities.add({
    wall: {
      positions:
        geometry.coordinates[0][0].length == 3
          ? Cesium.Cartesian3.fromDegreesArrayHeights(coordinates)
          : Cesium.Cartesian3.fromDegreesArray(coordinates),
      maximumHeights: maximumHeight,
      minimumHeights: minimumHeight,
      material: new Cesium.ImageMaterialProperty({
        transparent: true, //设置透明
        image: getColorRamp({
          0.0: rgba.withAlpha(1.0).toCssColorString().replace(")", ",1.0)"),
          0.045: rgba.withAlpha(0.8).toCssColorString(),
          0.1: rgba.withAlpha(0.6).toCssColorString(),
          0.15: rgba.withAlpha(0.4).toCssColorString(),
          0.37: rgba.withAlpha(0.2).toCssColorString(),
          0.54: rgba.withAlpha(0.1).toCssColorString(),
          1.0: rgba.withAlpha(0).toCssColorString(),
        }), //Canvas
      }),
    },
    polyline: {
      positions:
        geometry.coordinates[0][0].length == 3
          ? Cesium.Cartesian3.fromDegreesArrayHeights(coordinates)
          : Cesium.Cartesian3.fromDegreesArray(coordinates),
      width: option.width || 5,
      material: rgba,
      clampToGround: clampToGround ?? true,
      zIndex: 10,
    },
  });
  entity.graphicType = 'wall'
  entity.graphicName = option.graphicName
  entity.entityProperties = option.entityProperties //entityProperties
  return entity
}
const getColorRamp = (val: any) => {
  if (val == null) {
    val = { 0.0: 'blue', 0.1: 'cyan', 0.37: 'lime', 0.54: 'yellow', 1: 'red' }
  }
  var ramp = document.createElement('canvas')
  ramp.width = 1
  ramp.height = 100
  var ctx: any = ramp.getContext('2d')
  var grd = ctx.createLinearGradient(0, 0, 0, 100)
  for (var key in val) {
    grd.addColorStop(1 - Number(key), val[key])
  }
  ctx.fillStyle = grd
  ctx.fillRect(0, 0, 1, 100)
  return ramp
}
const removeWall = () => {
  entityWall && viewer.entities.remove(entityWall)
}

const drawTerrainGrid = () => {
  let gridOptions = {
    lineColor: "#ffffcc",
    lineAlpha: 0.5,
    lineWidth: 1,
    fillClear: "#887070",
    fillAlpha: 0.02,
    clampToGround: false,
    elevation: 0,
    features: [],
    height: 1,
    name: ''
  }
  getTerrainHeight(kuangData.geometry, (features: any) => {
    gridOptions.features = features
    if (!features?.length) {
      console.log('模型数据计算失败')
      return
    }
    drawModelGrid(gridOptions)
    console.log('gridOptions', gridOptions);

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
  hasTerrainGrid.value = true
  removePolygon()
}
const clearModelGrid = () => {
  rectangleGrid && rectangleGrid.destroy()
  rectangleGrid = null
}

const enterUnderGround = () => {
  const { scene } = viewer
  const { globe } = viewer.scene
  const { imageryLayers } = viewer
  scene.globe.depthTestAgainstTerrain = false
  scene.screenSpaceCameraController.inertiaZoom = 0.5 //调整相机惯性缩放时长
  scene.screenSpaceCameraController.enableCollisionDetection = false //禁用相机与地形的碰撞检测
  scene.highDynamicRange = false //关闭高动态范围渲染
  scene.skyAtmosphere.show = false //关闭大气
  scene.skyBox.show = false //关闭天空盒
  scene.fog.enabled = false //关闭雾
  // globe.baseColor = Cesium.Color.BLACK
  globe.baseColor = Cesium.Color.TRANSPARENT
  if (imageryLayers && imageryLayers.length > 0) {
    // 遍历所有的影像，把影像透明度调整为0.7
    for (let index = 0; index < imageryLayers.length; index++) {
      const layer = imageryLayers.get(index)
      layer.alpha = 0
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
  addTerrain()
}

let gridPickSearch: any
const initGridPickSearch = () => {
  // 实例网格拾取
  gridPickSearch = new gs3d.tools.areaFeaturePick({
    viewer,
    callback: (pm: any, type: any) => {
      console.log('拾取回调', pm, type)//pm为拾取的geojson，type分为三种：1.'draw'：本次为绘制的回调 2.'clear'：本次为清除事件的回调 3.'checkGrid'：本次为开启网格拾取的回调 
    },
  })
}
const activate = (type: string) => {
  if (!gridPickSearch) {
    initGridPickSearch()
  }
  console.log('绘制')
  // 调用绘制方法
  gridPickSearch.activate({
    type: type,
    option: {
      graphicName: type == "point" ? "pointGra" : "otherGra",
      geoLevel: null,//网格层级，可选，若不传或值为null会自动取当前地图的网格层级
      maxGridNumber: 100000, //最大网格数，可选，默认为100000
      color: "#ff0000",//颜色(适用于：点、线、面、矩形)
      opacity: type == "polygon" ? 0.4 : 1,//不透明度(适用于：点、线、面、矩形)
      width: 2,//尺寸(适用于：点、线)
      fill: true,//是否填充内部(适用于：面、矩形),
      outline: true,//外边线(适用于：面、矩形)
      outlineColor: "#ff0000",//外边线颜色(适用于：点、面、矩形)
      outlineWidth: 1,////外边线宽度(适用于：点、矩形)
      height: 0,//底部高度(适用于：面)
      extrudedHeight: 0,//实体高度(适用于：面)
      isContinuous: true,//是否连续绘制，默认true，即默认连续点击(适用于：点)
      // isPerCallBack: true,//暂无法使用,连续绘制时是否每绘一个点就返回该个点，结束时不再返回，默认false。若项目中需要此需求，可参考mouseManager.html【鼠标管理】中动态连续绘制的实现方式
      showLabel: true,//是否显示label，默认true(适用于：点)
      clampToGround: false,//是否贴地，默认false(适用于：线、面)
      showImage: true,//是否显示为图片，默认true(适用于：点)
      imageOption: {
        distance: { near: 0, far: 30000000 }, //图标显示距离范围,默认near:0,far:30000000
        url: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAA3NJREFUWEetlk1oE0EUx/9vY5U2m9ZaQQU/2k3VfuxGoRUFPejFouDBD/Sg56og9iZ6Um96E0X8wJseBBWhglREvCjiR7FkoxVsdosUaaVWbTbWpuk+2dSKNjs7Sdq5znv//2/ezJsZQpFjtNZoIIWaQ8zLsuBKAEMhwqBLyutIMv6lSDlQIQnfVxrVoXncoRC1MWOTKIcInZMuPai04zcK0fVipABpLXaUwR0A1hYqCuCJy3Sx0o53ynICAZy62G0QH5CJCCsCPhO2EmeD8oUAjmY8BLCjVPPpPIX4eEUycUkM6TOT0vQzBDo9W/PpfGbsj9jmHT+9vAqko0Y7M67Nlfm0DhFaw0mze6ZuHoCjGW8AtEgABgh4wUSf4HILKBcfCcphxvWIbR4OBHA04yCAW8UK/dLWrcmyew2ErUG5WYXrF/Ylkv/G/FcBRzM8cw/CfzBvV+3EY9G0oxnnAZwI6IqjYStxNQjgK4BFAoFzqmWekp0NJ6p3ganNL46B+xHL3OMLMNrQUKNkyoYDVr9OtRNxGUBa048w6IogzlQtM+YL4GiGAUBkMKRa5lKZuTfv1DathxJ66xvL+Kra5mJfgJ/R5s0uK88EJt2qZbYWAsD19ZVpt/yHoOcnwpY53xcgtUpvpBC9F5mElbEq6usblUE4tc1tUJQuQVxeJf92gVOnLwHRoLABQPsiVvyeDCDwFiX0qkmzybcCb1payhq+ZTLiQ5i/fzNjnTp9O4geBSziecSKbxG3oeT1I9DzCuXnTr+tGK9vbppwlXdBFSKw5B6QrGBKnIbB7rlJVp5V9cdfpqPGDpd5o+zxIsCpcEMrqL/nu7ACuTbSjFcANsj2uth5Ai6HLfPYzLy8xyhVq28lhby/QHmxJqJ4Al6GLdP3K+f7IfkD8XSOAEZUy6wJgPOfmhMIQlZNmmXBBzNgdpYQ6Q/V86tbu7snSgbwEkuBYGBEzajLaeDFmGwbpd9yT8BrNWZ4B1M+CJ/HaayxpoBrO9fUcsWpiJQW20vgu5J4O5xxW2ng3UihugUD5O6IOv0QiG76ihN64fI21U4MFWpeVAWmRVNRo53yfs3UM65gV01ffKAY85IAcpXQYh0AX5gy456QO293eX9Pf7HmJQNMQRgnvQ/sJLJ7qqzej6WYzwrASx5frTcu+JjoLdXcy/sNddw9MPLcyvEAAAAASUVORK5CYII=',
        width: 40, //图片宽，默认40，
        height: 40 //图片高，默认40
      },
      scaleByDistance: null, //根据距离缩放点的属性值，数组中依次[近距，近距缩放比例，远距，远距缩放比例]，比如点的原始属性width：10，outlineWidth：10，那么根据[1000,1,10000,0.5]表示为，当点视角在1000米高度时，点的属性值缩放比例为1，即width：10，outlineWidth：10；当视角在10000米高度时，点的属性值缩放比例为0.5，即width：5，outlineWidth：5，默认null。(适用于：点)
      translucencyByDistance: null, //根据与相机的距离设置半透明性。数组中依次[近距，近距缩放比例，远距，远距缩放比例]，比如[1000,0.5,10000,1]，那么在1000米高度时，所看到的图形透明度为0.5，高于10000时，透明度为1，默认null。(适用于：点)
      distanceDisplayCondition: [0, null], //在距离相机多远的地方显示此点，数组中依次[最小高度，最大高度]，比如[1000,10000]，即在1000-10000米范围内才能看到图形数据。默认[0, null]。(适用于：点,线,面,矩形)
      disableDepthTestDistance: null //指定要禁用深度测试的相机与相机之间的距离。比如disableDepthTestDistance：50000，即对象在高度50000下不再受深度的影响而显示离。默认永远不受深度影响。(适用于：点)
    }
  })
}

let graphicGridArray: Array<any> = []
const drawGraphicGrid = (type: string) => {
  console.log('drawGraphicGrid：', type);
  let graphicGridJson = type === 'suiDao' ? suiDaoJson : type === 'camera' ? deviceJson.camera : deviceJson.camera
  let gridOptions = {
    lineColor: "#FFFF00",
    lineAlpha: 0.75,
    lineWidth: 1,
    fillClear: "#b2985bfb",
    fillAlpha: 1,
    clampToGround: false,
    elevation: 0,
    features: [],
    height: 1,
    name: ''
  }
  let features: any = graphicGridJson.map((geo: any) => {
    const line = turf.lineString([
      [geo.geoNumScope[1], geo.geoNumScope[0]],
      [geo.geoNumScope[3], geo.geoNumScope[2]],
    ])
    const bbox = turf.bbox(line)
    const feature = turf.bboxPolygon(bbox, { properties: { id: geo.geoNum4, bbox: bbox } })
    const centroid = turf.centroid(feature)
    let center = turf.getCoord(centroid)
    feature.properties['center'] = center
    feature.properties['height'] = geo.height
    feature.properties['extruded'] = geo.extrudedHeight || 30
    feature.properties['id'] = geo.deviceId || "device"
    return feature
  })

  gridOptions.features = features

  let graphicGrid = new gs3d.grid.rectangleGrid(viewer)
  graphicGrid.draw(gridOptions)
  console.log('gridOptions', gridOptions);

  graphicGridArray.push(graphicGrid)
}
const clearGraphicGrid = () => {
  graphicGridArray.forEach((item) => {
    item && item.destroy()
  })
  graphicGridArray = []
}

const drawGraphic = (type: string) => {
  let graphic = {
    type: 'Feature',
    properties: {},
    geometry: {
      coordinates: tubeJson[type],
      type: 'LineString',
    }
  }
  let entity = gs3d.common.draw.drawGraphic(viewer, graphic.geometry, {
    graphicName: `graphic_${type}`,
    width: type === 'wind' ? 3 : type === 'boom' ? 2 : type === 'water' ? 3 : type === 'wifi' ? 1 : 2,
    color: type === 'wind' ? "green" : type === 'boom' ? 'red' : type === 'water' ? 'blue' : type === 'wifi' ? 'yellow' : '',
    showBillBoard: false,
    // clampToGround: true
  })
  gs3d.common.position.locationEntity(viewer, entity)
}
const clearGraphic = () => {
  gs3d.common.draw.clearAllGraphic(viewer)
  // gs3d.common.draw.clearGraphicByGraphicName(viewer, 'graphic_wind')
  // gs3d.common.draw.clearGraphicByGraphicName(viewer, 'graphic_boom')
  // gs3d.common.draw.clearGraphicByGraphicName(viewer, 'graphic_water')
  // gs3d.common.draw.clearGraphicByGraphicName(viewer, 'graphic_wifi')
}

const changeLayer = (_e: any, { checkedKeys }: { checkedKeys: number[] }) => {
  clearGraphic()
  clearGraphicGrid()
  checkedKeys.forEach((item: number) => {
    showLayer(item)
  })
}

const showLayer = (item: number) => {
  if (item === 3) {
    drawGraphicGrid('suiDao')
  }
  if (item === 4) {
    drawGraphic('wind')
  }
  if (item === 5) {
    drawGraphic('boom')
  }
  if (item === 6) {
    drawGraphic('water')
  }
  if (item === 7) {
    drawGraphic('wifi')
  }
  if (item === 10) {
    drawGraphicGrid('camera')
  }
}

let showBox = ref(false)
const showInformation = () => {
  showBox.value = true
  showProcessBox.value = false
}

let showProcessBox = ref(false)
const showProcess = () => {
  showProcessBox.value = true
  showBox.value = false
}

let processFrom = reactive({
  time: '',
  operator: '',
  range: '',
  clear: '2'
})

let video_show = ref(false)
let showNormalBox = ref(false)
let showUnusualBox = ref(false)
let unusual_step = ref(1)
let camera_video_show = ref(false)
</script>

<template>
  <div class="header">
    <div class="title">
      <h1>时空网格矿山编码融合系统</h1>
    </div>
  </div>
  <video controls class="mp4_video" v-show="video_show">
    <source src="./assets/1154333232-1-1921.mp4" type="video/mp4" />
  </video>

  <video controls class="camera_video" v-show="camera_video_show">
    <source src="./assets/camera.mp4" type="video/mp4" />
  </video>
  <div id="mapContainer"></div>

  <div class="location" @click="addPolygon()"> <span>树崆坪</span> </div>
  <div id="layer-control-box" v-show="show_layer_control_box">
    <span class="title">展示图层</span>
    <div class="content">
      <el-tree :data="layerControlOptions" highlight-current show-checkbox @check="changeLayer" node-key="id" />
    </div>
  </div>

  <div class="operate-btn">
    <el-upload class="upload-demo" action="#" :show-file-list="false" style="display: inline-block; margin-left: 10px"
      @change="showInformation">
      <el-button>信息导入</el-button>
    </el-upload>
    <el-button @click="showProcess">爆破流程</el-button>
    <el-button @click="activate('line')">画线</el-button>
  </div>

  <div id="information-box" v-show="showBox">
    <span class="title">爆破历史信息</span>
    <div class="details">
      <ul>
        <li>负责人：王阳</li>
        <li>爆破时间：2024年2月12日</li>
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
    <div class="operate"> <el-button type="primary" @click="showBox = false">关闭</el-button></div>
  </div>

  <div id="process-box" v-show="showProcessBox" class="form_box">
    <span class="title">爆破流程</span>
    <el-form label-width="80px">
      <el-form-item label="操作人">
        <el-input v-model="processFrom.operator" />
      </el-form-item>
      <el-form-item label="爆破时间" class="time-input">
        <el-date-picker type="date" placeholder="选择日期" v-model="processFrom.time"></el-date-picker>
      </el-form-item>

      <el-form-item label="爆破区域">
        <el-input v-model="processFrom.range" />
      </el-form-item>
      <el-form-item label="人员清场">
        <el-radio v-model="processFrom.clear" label="1">是</el-radio>
        <el-radio v-model="processFrom.clear" label="2">否</el-radio>
      </el-form-item>
    </el-form>
    <div class="operate"> <el-button type="primary" @click="showProcessBox = false" class="boom-btn"
        :disabled="processFrom.clear === '2'">确认爆破</el-button></div>
  </div>

  <div id="normal_device_box" v-show="showNormalBox">
    <span class="title">设备信息</span>
    <div class="details">
      <ul>
        <li>设备名称：二号风机</li>
        <li>实时功率：74.5 KW</li>
        <li>输出电压：303.0 V</li>
        <li>输出电流：194.0 A</li>
        <li>轴承温度：28.6 °C</li>
        <li>线圈温度：26.8 °C</li>
        <li>实时振动：0.0 mm/S</li>
        <li>实时风速：3.3 m/S</li>
        <li>实时负压：0.6 kpa</li>
      </ul>
    </div>
    <div class="operate"> <el-button type="primary" @click="showNormalBox = false">关闭</el-button></div>
  </div>
  <div v-show="showUnusualBox" :class="unusual_step === 1 ? 'unusual_device_box' : 'form_box'">
    <span class="title">异常设备</span>
    <div class="details" v-if="unusual_step === 1">
      <ul>
        <li>设备名称：环境监测</li>
        <li>使用地点：西二巷304Q4</li>
      </ul>
    </div>
    <el-form label-width="80px" v-else>
      <el-form-item label="故障现象">
        <el-input v-model="processFrom.operator" />
      </el-form-item>
      <el-form-item label="原因分析">
        <el-input v-model="processFrom.operator" />
      </el-form-item>

      <el-form-item label="处理措施">
        <el-input v-model="processFrom.range" />
      </el-form-item>
      <el-form-item label="处理人">
        <el-input v-model="processFrom.range" />
      </el-form-item>
      <el-form-item label="处理时间" class="time-input">
        <el-date-picker type="datetime" placeholder="选择日期时间" v-model="processFrom.time"></el-date-picker>
      </el-form-item>
      <el-form-item label="处理结果">
        <el-radio v-model="processFrom.clear" label="1">已恢复</el-radio>
        <el-radio v-model="processFrom.clear" label="2">未恢复</el-radio>
      </el-form-item>
    </el-form>
    <div class="operate">
      <el-button type="warning" @click="unusual_step = 2" v-if="unusual_step === 1">异常上报</el-button>
      <el-button type="primary" @click="showUnusualBox = false" v-else>提交</el-button>
    </div>
  </div>
</template>

<style scoped lang="scss">
.mp4_video {
  top: 15vh;
  right: 30vw;
  z-index: 9;
  position: fixed;
  width: 600px;
  height: 338px;
}

.camera_video {
  top: 15vh;
  right: 30px;
  z-index: 9;
  position: fixed;
  width: 450px;
  height: 288px;
}

.header {
  display: flex;
  justify-content: space-between;
  /* align-items: center; */
  position: fixed;
  height: 100px;
  width: 100%;
  background-image: url(assets/header-bg.webp);
  background-size: 100% 100%;
  z-index: 9;

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
    }
  }
}

#mapContainer {
  height: 100vh;
  width: 100vw;
}

.operate-btn {
  top: 20px;
  right: 50px;
  z-index: 9;
  position: fixed;
  display: flex;

  button {
    background-color: #1762e8c7;
    border-color: #3B7BED;
    margin-right: 10px;

    :deep(span) {
      color: #fff;
      opacity: 1
    }


  }
}

#information-box {
  color: white;
  width: 350px;
  height: 500px;
  background-image: url(assets/border-top-right.webp);
  background-size: 100% 100%;
  position: fixed;
  top: 80px;
  right: 20px;
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

.form_box {
  color: white;
  width: 350px;
  height: 500px;
  background-image: url(assets/border-top-right.webp);
  background-size: 100% 100%;
  position: fixed;
  top: 80px;
  right: 20px;
  z-index: 9;
  font-weight: 500;
  background-color: #063584a4;

  .title {
    font-size: 20px;
    position: relative;
    top: 3px;
    left: 45px;
  }

  :deep(.el-form) {
    width: 90%;
    margin: 20px auto;

    .time-input {
      .el-date-editor.el-input {
        width: 100%;

        .el-input__wrapper {
          .el-input__inner {
            padding-left: 0;
          }
        }
      }
    }

    .el-form-item__label {
      color: #fff;
    }

    .el-form-item__content {
      .el-input__wrapper {
        background-color: transparent;
        padding: 0;
        box-shadow: none;


        .el-input__inner {
          border: 0;
          border-bottom: 1px solid #025eff;
          color: #fff;
        }
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

  .operate {
    text-align: center;
    margin-top: 40px;

    .boom-btn {
      background-color: #d01313;
      border: none;


    }

    .el-button.is-disabled {
      background-color: #d26363;
    }
  }
}

.location {
  width: 200px;
  height: 65px;
  background-image: url(assets/internet_1.webp);
  background-size: 100% 100%;
  position: fixed;
  top: 70px;
  left: 50px;
  z-index: 9;
  cursor: pointer;

  span {
    font-size: 20px;
    font-weight: 500;
    position: relative;
    top: 18px;
    left: 80px;
    color: #fff;
  }
}

#layer-control-box {
  color: white;
  width: 200px;
  height: 400px;
  background-image: url(assets/border-top-right.webp);
  background-size: 100% 100%;
  position: fixed;
  top: 150px;
  left: 50px;
  z-index: 9;
  font-weight: 500;

  .title {
    position: relative;
    top: 3px;
    left: 25px;
  }

  .content {
    padding-top: 10px;
  }
}

#normal_device_box {
  color: white;
  width: 280px;
  height: 480px;
  background-image: url(assets/border-top-right.webp);
  background-size: 100% 100%;
  position: fixed;
  top: 80px;
  right: 20px;
  z-index: 9;
  font-weight: 500;

  .title {
    font-size: 20px;
    position: relative;
    top: 3px;
    left: 45px;
  }

  .details {
    margin-top: 30px;
    margin-left: 15px;

    ul {
      list-style-type: none;

      li {
        margin-bottom: 10px;
      }
    }
  }

  .operate {
    text-align: center;
    margin-top: 40px;
  }
}

.unusual_device_box {
  color: white;
  width: 280px;
  height: 480px;
  background-image: url(assets/border-top-right.webp);
  background-size: 100% 100%;
  position: fixed;
  top: 80px;
  right: 20px;
  z-index: 9;
  font-weight: 500;

  .title {
    font-size: 20px;
    position: relative;
    top: 3px;
    left: 45px;
  }

  .details {
    margin-top: 30px;
    margin-left: 15px;

    ul {
      list-style-type: none;

      li {
        margin-bottom: 10px;
      }
    }
  }

  .operate {
    text-align: center;
    margin-top: 40px;
  }
}
</style>

<style lang="scss">
#layer-control-box {
  .content {
    .el-tree {
      background-color: transparent;
      color: #fff;
      height: 75%;
      overflow: auto;
      font-size: 16px;

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
}

.el-picker__popper {
  background-color: #063584e8 !important;

  .el-date-picker {
    background-color: #063584e8;
    color: #fff;

    .el-date-picker__time-header {
      .el-date-picker__editor-wrap {
        .el-input__wrapper {
          background-color: transparent;
          padding: 0;
          box-shadow: none;


          .el-input__inner {
            border: 0;
            border-bottom: 1px solid #025eff;
            color: #fff;
          }
        }
      }
    }

    .el-picker-panel__icon-btn {
      color: #fff;
    }

    .el-date-picker__header-label {
      color: #fff;
    }

    .el-date-table th {
      color: #fff;
    }

    .el-picker-panel__footer {
      background-color: #063584e8;

      button {
        background-color: transparent;
        color: #fff;
        border: none;
      }
    }

  }
}
</style>
