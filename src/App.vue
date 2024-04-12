<!--
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2024-04-10 09:40:35
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2024-04-12 10:45:10
 * @FilePath: /gis-test/src/App.vue
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
<script setup lang="ts">
// import * as gs3d from '@gs3d/sdk'
import * as gs3d from '@/utils/gs3d/index'
import { onMounted } from 'vue';
// import geoData from '@/static/geo'
import kuangData from '@/static/kuang'
let viewer: any;
const { Cesium } = window;
let options = {
  height: 100.76,        // 楼高
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
    // "coordinates": [[[125.37483772900009, 43.81780773100007], [125.37489081600006, 43.81787073000004], [125.37489330400001, 43.81787369800003], [125.37487638000005, 43.817923585000074], [125.37487617200009, 43.817924197000025], [125.37485852500004, 43.817976172000044], [125.37485502100003, 43.817977721000034], [125.37476166900001, 43.81801896200005], [125.37473035300002, 43.81803279300004], [125.37473032300011, 43.81803280400004], [125.37467623500004, 43.81805669800008], [125.37467039900002, 43.81805927500005], [125.37451115700003, 43.81787028700006], [125.37445321400003, 43.81780152500005], [125.37439819200006, 43.81773622500003], [125.37434317100008, 43.81767091800003], [125.37430077400006, 43.81762060300008], [125.3742881390001, 43.817605610000044], [125.37423570900012, 43.81754338600007], [125.37422535500002, 43.817531098000075], [125.3742244450001, 43.81753001800007], [125.37425604100008, 43.81746041400004], [125.37425713200003, 43.81745801000005], [125.37426495800003, 43.817454557000076], [125.37428034100003, 43.817447755000046], [125.37428724400002, 43.81744470600006], [125.3743103060001, 43.81743451700004], [125.37431792600012, 43.81741773400006], [125.37431733400001, 43.81741759400006], [125.37435180600005, 43.81734164300008], [125.37435241300011, 43.81734178700003], [125.3743562840001, 43.817333261000044], [125.37447220600006, 43.817360853000025], [125.37447315700001, 43.81735615400004], [125.37436758100012, 43.81733102000004], [125.3743628420001, 43.81732989400007], [125.37435829300011, 43.817328814000064], [125.37436005300003, 43.817324943000074], [125.37435339500007, 43.81731313800003], [125.37433935700005, 43.81728824500004], [125.37433650500009, 43.81728318800003], [125.37435580600004, 43.81724067300007], [125.37439761300004, 43.817148588000066], [125.37440461100005, 43.817148864000046], [125.37460253100005, 43.81715666000008], [125.37472417000004, 43.81716145100006], [125.37482594500011, 43.81716546100006], [125.37505804600005, 43.81717460300007], [125.37505321900005, 43.817238856000074], [125.37516491400004, 43.81724325600004], [125.37514843700001, 43.81746253000006], [125.3751429020001, 43.817536215000075], [125.37513736800008, 43.817609909000055], [125.37513152500003, 43.817687644000046], [125.37490388300012, 43.817678674000035], [125.37477854600002, 43.81773404000006], [125.37466923900001, 43.817604413000026], [125.37466832900009, 43.817604810000034], [125.37466663900011, 43.817605558000025], [125.37466558300002, 43.81760602600008], [125.37467494500004, 43.817617135000035], [125.37472802400009, 43.81768013100003], [125.37477661800006, 43.81773780000003], [125.37477767900009, 43.81773732900007], [125.37477821000004, 43.81773709400005], [125.37483772900009, 43.81780773100007]]],
    "coordinates": [[[111.181279144793564, 31.363959102231885], [111.180659797649355, 31.363911025208314], [111.179758929075945, 31.364175448533619], [111.178942516931315, 31.363670639721651], [111.177929039786193, 31.363598523955773], [111.177112627641549, 31.363814871087428], [111.176070998353509, 31.36299755708858], [111.175113825494293, 31.362901402033284], [111.173649914062509, 31.363093712045515], [111.172749045489056, 31.363766793990077], [111.170834699770552, 31.366435035702661], [111.172157850487764, 31.368502269997485], [111.17255198048862, 31.369535870093689], [111.171932633344426, 31.36948779592268], [111.171763720486879, 31.370064684351714], [111.173368392633307, 31.373045218152502], [111.175029369065513, 31.373429796272905], [111.176690345497761, 31.373910516709948], [111.179195886217556, 31.373766300837065], [111.181391753365276, 31.3726606384581], [111.182405230510369, 31.371002120495923], [111.183869141942154, 31.369968536526137], [111.183418707655449, 31.369776240579867], [111.184432184800528, 31.366627338485408], [111.18451664122928, 31.365016790529037], [111.182095556938236, 31.364223525421934], [111.181279144793564, 31.363959102231885]]],
    "type": "Polygon"
  }
}

let flag = true
const changeShow = async () => {
  if (flag) {
    viewer.scene.terrainProvider = new Cesium.EllipsoidTerrainProvider({});
    gs3d.grid.buildGrid.draw(options, viewer)
  } else {
    viewer.scene.setTerrain(
      new Cesium.Terrain(
        Cesium.CesiumTerrainProvider.fromIonAssetId(1),
      ),
    );
  }
  flag = !flag
  // 加载谷歌3DTails没生效
  // viewer.imageryLayers.remove(viewer.imageryLayers.get(0));
  // const tileset = await Cesium.Cesium3DTileset.fromIonAssetId(2275207);
  // viewer.scene.primitives.add(tileset);
}
let event = [
  {
    id: 'show-hidden',
    clickEvent: () => {
      // gs3d.grid.buildGrid.changeShow()
      changeShow()
    }
  },
  {
    id: 'fill-show-hidden',
    clickEvent: () => {
      gs3d.grid.buildGrid.changeBoxShow()
    }
  },
  {
    id: 'border-show-hidden',
    clickEvent: () => {
      gs3d.grid.buildGrid.changeOutlineShow()
    }
  },
]


onMounted(async () => {
  const defopt = {
    msaaSamples: 4,
    terrain: Cesium.Terrain.fromWorldTerrain(),
  }

  viewer = gs3d.global.initViewer('mapContainer', defopt);
  viewer.scene.globe.depthTestAgainstTerrain = true;
  // const viewer = new Cesium.Viewer('mapContainer', {
  //   terrain: Cesium.Terrain.fromWorldTerrain(),
  // });
  // viewer.camera.flyTo({
  //   destination: Cesium.Cartesian3.fromDegrees(111.181279144793564, 31.363959102231885, 400),
  //   orientation: {
  //     heading: Cesium.Math.toRadians(0.0),
  //     pitch: Cesium.Math.toRadians(-15.0),
  //   }
  // });


  // viewer.imageryLayers.remove(viewer.imageryLayers.get(0));
  // viewer.terrainProvider = Cesium.createWorldTerrainAsync({
  //   requestWaterMask: true, // required for water effects
  //   requestVertexNormals: true // required for terrain lighting
  // });
  // viewer.scene.globe.terrainExaggeration = 0;
  // viewer.scene.globe.terrainExaggerationRelativeHeight = 1;
  let geojsonOptions = {
    clampToGround: true //使数据贴地
  };
  Cesium.GeoJsonDataSource.load(polygon, geojsonOptions).then((dataSource: any) => {
    viewer.dataSources.add(dataSource);
    viewer.flyTo(dataSource);
    gs3d.grid.buildGrid.draw(options, viewer)
  })


  let position = Cesium.Cartesian3.fromDegrees(111.185279144793564, 31.373959102231885)
  const entity = viewer.entities.add({
    name: 'dem',
    position: position,
    model: {
      uri: '/src/assets/qs.gltf',
      minimumPixelSize: 1000,
      // maximumScale: 220000,

      heightReference: Cesium.HeightReference.NONE,
      imageBasedLightingFactor: new Cesium.Cartesian2(4, 1)
    }
  })
  var angle = Cesium.Math.toRadians(-90); // 旋转45度
  var axis = new Cesium.Cartesian3(0, 0, 1); // 绕z轴旋转

  // 创建一个四元数表示旋转
  var rotation = Cesium.Quaternion.fromAxisAngle(axis, angle);
  entity.orientation = rotation;
  let handle = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas)
  handle.setInputAction(async (e: any) => {
    let position = e.position
    let pick = viewer.scene.pick(position)
    console.log('click', pick)
  }, Cesium.ScreenSpaceEventType.LEFT_CLICK)

  handle.setInputAction(async (e: any) => {
    console.log('wheel', e)
  }, Cesium.ScreenSpaceEventType.e)

  event.forEach(item => {
    let dom = document.getElementById(item.id)
    if (dom) {
      dom.addEventListener('click', item.clickEvent)
    }
  })
})





</script>

<template>

  <div id="mapContainer"></div>
  <div class="active-btn">
    <button id="show-hidden">显/隐</button>
    <button id="fill-show-hidden">填充显/隐</button>
    <button id="border-show-hidden">边框显/隐</button>
  </div>
</template>

<style scoped>
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

button {
  margin-right: 5px;
}
</style>
