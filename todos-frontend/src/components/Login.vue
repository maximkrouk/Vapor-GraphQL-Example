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
            fetch("http://localhost:8080/users/login", {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(this.input)
            })
            .then((request) => {
                if (request.statusText.toLowerCase() == "ok") {
                    request
                        .json()
                        .then((json) => {
                            console.log(JSON.stringify(json))
                            localStorage.setItem('jwt', json.token)
                        })
                        .then(() => this.$emit('onLogin'))
                }
            })
        },
        toRegister() {
            this.$emit("toRegister")
        }
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