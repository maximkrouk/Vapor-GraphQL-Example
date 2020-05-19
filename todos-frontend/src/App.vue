<template>
  <div id="app">
    <RegisterVue v-if="!login && jwt == null" v-on:toLogin="toLogin" v-on:onLogin="onLogin"/>
    <LoginVue v-if="login && jwt == null" v-on:toRegister="toRegister" v-on:onLogin="onLogin"/>
    <MainVue v-if="jwt != null" v-on:onLogout="onLogout"/>
  </div>
</template>

<script>
import RegisterVue from './components/Register.vue'
import LoginVue from './components/Login.vue'
import MainVue from './components/Main.vue'

export default {
  name: 'App',
  data() {
    return {
      jwt: null,
      login: true
    }
  },
  mounted() {
     window.addEventListener('load', () => {
        this.onLogin()
      })
  },
  methods: {
    toLogin() {
      this.login = true
    },
    toRegister() {
      this.login = false
    },
    onLogin() {
      var jwt = localStorage.getItem('jwt')
      if (jwt != null) { 
        this.jwt = jwt
      }
    },
    onLogout() {
      localStorage.removeItem('jwt')
      this.jwt = null
    }
  },
  components: {
    RegisterVue,
    LoginVue,
    MainVue
  }
}
</script>

<style>
</style>
