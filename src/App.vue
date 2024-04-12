<script setup lang="ts">
import * as gs3d from '@/utils/gs3d/index'
import { onMounted, ref } from 'vue';
import kuangData from '@/static/kuang'
let viewer: any;
const { Cesium } = window;
let options = {
  height: 1000.76,        // 楼高
  floor: 5,            // 楼层数
  lineColor: "#FFA500", // 边线色
  lineAlpha: 0.5,
  outlineShow: true,    // 边线默认值
  fillClear: "#0000ff", // 填充色
  fillAlpha: 0.05,       // 填充色透明度
  boxShow: true,        // 填充默认值
  elevation: 0,         // 高程
  geometries: [{ id: '', rectangle: [0, 0, 0, 0] }],       // GEO信息 [{ id: String, rectangle:[west, south, east, north] }]
};

options.geometries = kuangData.map((geo) => {
  return {
    id: geo.geoNum4,
    rectangle: [geo.geoNumScope[1], geo.geoNumScope[0], geo.geoNumScope[3], geo.geoNumScope[2]]
  }
})

const polygon = {
  "type": "Feature",
  "properties": {
    "id": "7kuMolrTCYE",
    "name": "7kuMolrTCYE"
  },
  "geometry": {
    "coordinates": [[[111.181279144793564, 31.363959102231885], [111.180659797649355, 31.363911025208314], [111.179758929075945, 31.364175448533619], [111.178942516931315, 31.363670639721651], [111.177929039786193, 31.363598523955773], [111.177112627641549, 31.363814871087428], [111.176070998353509, 31.36299755708858], [111.175113825494293, 31.362901402033284], [111.173649914062509, 31.363093712045515], [111.172749045489056, 31.363766793990077], [111.170834699770552, 31.366435035702661], [111.172157850487764, 31.368502269997485], [111.17255198048862, 31.369535870093689], [111.171932633344426, 31.36948779592268], [111.171763720486879, 31.370064684351714], [111.173368392633307, 31.373045218152502], [111.175029369065513, 31.373429796272905], [111.176690345497761, 31.373910516709948], [111.179195886217556, 31.373766300837065], [111.181391753365276, 31.3726606384581], [111.182405230510369, 31.371002120495923], [111.183869141942154, 31.369968536526137], [111.183418707655449, 31.369776240579867], [111.184432184800528, 31.366627338485408], [111.18451664122928, 31.365016790529037], [111.182095556938236, 31.364223525421934], [111.181279144793564, 31.363959102231885]]],
    "type": "Polygon"
  }
}

let show_reset_btn = ref(false)
let show_build_btn = ref(false)

onMounted(async () => {
  const defopt = {
    msaaSamples: 4,
    terrain: Cesium.Terrain.fromWorldTerrain(),
  }

  viewer = gs3d.global.initViewer('mapContainer', defopt);
  viewer.scene.globe.depthTestAgainstTerrain = true;

  let geojsonOptions = {
    clampToGround: true //使数据贴地
  };
  Cesium.GeoJsonDataSource.load(polygon, geojsonOptions).then((dataSource: any) => {
    viewer.dataSources.add(dataSource);
    console.log('dataSource：', dataSource);
    viewer.flyTo(dataSource);
    viewer.camera.moveEnd.addEventListener(flyingHandler);

    gs3d.grid.buildGrid.draw(options, viewer)
  })

  //缩放到一定层级 清除背景开始建模
  let flyingHandler = function () {
    viewer.camera.changed.addEventListener(async function () {
      // 获取当前相机高度
      let cameraHeight = viewer.camera.positionCartographic.height;
      console.log('cameraHeight：', cameraHeight);
      let baseLayer = viewer.imageryLayers.get(0);
      if (cameraHeight > 30000 && baseLayer) {
        // viewer.scene.terrainProvider = new Cesium.EllipsoidTerrainProvider({});
        gs3d.grid.buildGrid.draw(options, viewer)
        baseLayer.alpha = 0;
        show_reset_btn.value = true
        // viewer.imageryLayers.remove(viewer.imageryLayers.get(0));
      } else if (cameraHeight < 50000 && !baseLayer) {
        viewer.scene.setTerrain(
          new Cesium.Terrain(
            Cesium.CesiumTerrainProvider.fromIonAssetId(1),
          ),
        );

      }
    });
    viewer.camera.moveEnd.removeEventListener(flyingHandler);
  };


  let position = Cesium.Cartesian3.fromDegrees(111.185279144793564, 31.373959102231885)
  const entity = viewer.entities.add({
    name: 'dem',
    position: position,
    model: {
      uri: '/src/assets/low_dem.gltf',
      minimumPixelSize: 1000,
      // maximumScale: 220000,

      heightReference: Cesium.HeightReference.NONE,
      imageBasedLightingFactor: new Cesium.Cartesian2(4, 1)
    }
  })
  // var angle = Cesium.Math.toRadians(-90); // 旋转45度
  // var axis = new Cesium.Cartesian3(0, 0, 1); // 绕z轴旋转

  // // 创建一个四元数表示旋转
  // var rotation = Cesium.Quaternion.fromAxisAngle(axis, angle);
  // entity.orientation = rotation;
  let handle = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas)
  handle.setInputAction(async (e: any) => {
    let position = e.position
    let pick = viewer.scene.pick(position)
    console.log('click', pick)
  }, Cesium.ScreenSpaceEventType.LEFT_CLICK)


})

let showBox = ref(false)
const showInformation = () => {
  showBox.value = true
}

const reset = () => {
  let baseLayer = viewer.imageryLayers.get(0);
  baseLayer.alpha = 50;
}

</script>

<template>

  <div id="mapContainer"></div>
  <div class="active-btn">
    <el-button v-show="show_reset_btn" @click="reset">重置</el-button>
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
        <li>操作流程：
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
        content: "✓";
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
