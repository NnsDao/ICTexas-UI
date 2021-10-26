<template>
  <div>
    <router-view></router-view>
  </div>
</template>

<script>
export default {
  name: "App",
  components: {},
  mounted() {
    // if (document.body.clientHeight < 666 && document.body.clientWidth > 1000) {
    //   document.body.style.zoom = 0.9
    //   document.getElementById("app").style.marginTop = "50px"
    // } 
  }
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

body {
  width: 100%;
  height: auto;
  /* background-image: url("./assets/v2/game_board/bg.png");
  background-repeat: no-repeat;
  background-size: cover; */

  background-color: #f2f3f4;
  /* overflow: hidden; */
}

@media screen and (max-width: 1000px) {
  /* body {
    zoom: 0.55;
  } */

  /* #app {
    margin-top: 120px;
  } */
}

</style>
