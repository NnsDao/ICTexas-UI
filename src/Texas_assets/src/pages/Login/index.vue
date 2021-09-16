<template>
  <div>
    <div class="container">
      <img class="logo-img" src="../../assets/welcome.png" alt="" srcset="" />
      <h2 id="loginWelcome">Welcome to<br />Texas Holdem</h2>
      <a-button class="login-btn" @click="Login">Login</a-button>
    </div>
  </div>
</template>

<script>
import { defineComponent } from "vue";
import router from "../../router";
import TokenInfo from "../../utils/token";
import GameInfo from "../../utils/game";

export default defineComponent({
  setup() {
    const Login = async () => {
      await TokenInfo.Instance.login();
      await GameInfo.Instance.login();
      router.push("/room");
    };
    return {
      Login,
    };
  },
});
</script>


<style scoped>
h2 {
  font-weight: bold;
  margin: 0;
  margin-bottom: 30px;
}

.container {
  margin: 0 auto;
  margin-top: 60px;
  padding: 3.5rem 2.5rem 2rem 2.5rem;
  max-width: 365px;
  min-width: 300px;
  flex: 0 0 auto;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  /* border: 2px #d9d9da solid;
  border-radius: 4px; */
}

.logo-img {
  width: 100%;
  margin: 0 auto;
}

.login-btn,
.login-btn.primary {
  background-color: black;
  color: #fff;
  border: none;
  height: 50px;
  width: 400px;
  font-weight: bold;
  font-size: 20px;
}

.login-btn:hover,
.login-btn:focus {
  background-color: black;
  color: #fff;
  border: none;

  opacity: 0.9;
  box-shadow: 0 0 0 2px #ffffff, 0 0 3px 5px #29abe2;
  outline: 2px dotted transparent;
  outline-offset: 2px;
}

#loginWelcome {
  color: gold;
  font-size: 28px;
}
</style>


