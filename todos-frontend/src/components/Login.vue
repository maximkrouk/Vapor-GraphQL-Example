<template>
    <b-container class="h-100">
        <div class="d-flex align-items-center justify-content-center h-100 w-70">
            <div class="d-flex flex-column">
                <b-form-input class="mt-2" v-model="input.username" placeholder="Username"></b-form-input>
                <b-form-input class="mt-2" v-model="input.password" placeholder="Password"></b-form-input>
                <b-button variant="primary" class="w-75 mt-2 mx-auto" @click="login">Login</b-button>
                <b-button @click="toRegister" variant="outline-primary" class="w-75 mt-2 mx-auto">Go to register</b-button>
            </div>
        </div>
    </b-container>
</template>

<script>
import axios from 'axios'

export default {
    data() {
        return {
            input: {
                username: "",
                password: "",
            }
        }
    },
    methods: {
        login() {
            var reqBody = {
                "query" : `mutation Login { login(username:"${this.input.username}", password:"${this.input.password}") { token } }`
            }

            axios
            .post('http://localhost:8080/graphQL', reqBody)
            .then(response => {
                var content = JSON.parse(response.request.response)
                console.log(content)
                localStorage.setItem('jwt', content.data.login.token)
                this.$emit('onLogin')
            })
            .catch(error => console.error(error))
        },
        toRegister() {
            this.$emit("toRegister")
        },
    },
    computed: {
        jwt() {
            return localStorage.getItem('jwt')
        }
    }
}
</script>

<style>
</style>