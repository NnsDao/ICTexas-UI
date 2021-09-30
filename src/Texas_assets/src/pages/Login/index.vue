<template>
  <div class="container">
      <img
        class="logo-img"
        src="../../assets/v2/welcome.png"
        alt=""
        srcset=""
      />
      <a-button class="login-btn first" @click="Login"
        >Internet Identity</a-button
      >
      <a-button class="login-btn" @click="LoginWithStoic"
        >Stoic Identity</a-button
      >
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
      window.localStorage.setItem("identity", "internet");
      await TokenInfo.Instance.login();
      await GameInfo.Instance.login();
      router.push("/room");
    };

    const LoginWithStoic = async () => {
      window.localStorage.setItem("identity", "stoic");
      await TokenInfo.Instance.login();
      await GameInfo.Instance.login();
      router.push("/room");
    };
    return {
      Login,
      LoginWithStoic,
    };
  },
});
</script>


<style scoped>
.container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 100vw;
  height: 100vh;
}

.logo-img {
  width: 379px;
  height: 104px;
}

.login-btn,
.login-btn.primary {
  background: #0f6652;
  background-image: url("../../assets/v2/login/button.png");
  width: 764px;
  height: 66px;
  color: #f8f2d4;
  border: none;
  font-weight: 400;
  font-size: 25px;
}

.login-btn.first {
  margin: 142px 0 101px 0;
}

#loginWelcome {
  color: gold;
  font-size: 28px;
}
</style>


