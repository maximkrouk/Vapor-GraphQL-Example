<template>
  <div id="app">
    <RegisterVue v-if="!login && user == null" v-on:toLogin="toLogin" v-on:onLogin="onLogin"/>
    <LoginVue v-if="login && user == null" v-on:toRegister="toRegister" v-on:onLogin="onLogin"/>
    <MainVue v-if="user != null" v-on:onLogout="onLogout"/>
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
      user: null,
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
      var user = JSON.parse(localStorage.getItem('user'))
      if (user != null) { 
        this.user = user
      }
    },
    onLogout() {
      localStorage.removeItem('user')
      this.user = null
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
