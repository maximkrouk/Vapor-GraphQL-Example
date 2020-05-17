<template>
    <b-container class="h-100">
        <div class="d-flex align-items-center justify-content-center h-100 w-70">
            <div class="d-flex flex-column">
                <b-form-input class="mt-2" v-model="input.username" placeholder="Username"></b-form-input>
                <b-form-input class="mt-2" v-model="input.password" placeholder="Password"></b-form-input>
                <b-form-input class="mt-2" v-model="helper.confirmPassword" placeholder="Confirm password"></b-form-input>
                <div v-show="!doPasswordsMatch && !initialState"> 
                    "Passwords do not match"
                </div>
                <b-button variant="primary" class="w-75 mt-2 mx-auto" @click="register">Register</b-button>
                <b-button @click="toLogin" variant="outline-primary" class="w-75 mt-2 mx-auto">Go to login</b-button>
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
            },
            helper: {
                confirmPassword: "",
                initialState: true
            }
        }
    },
    methods: {
        register() {
            this.initialState = false
            if (!this.doPasswordsMatch) { return }
            fetch("http://localhost:8080/users/", {
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
                        .then((json) => localStorage.setItem('user', JSON.stringify(json)))
                        .then(() => this.$emit('onLogin'))
                }
            })
        },
        toLogin() {
            this.$emit('toLogin')
        }
    },
    computed: {
        doPasswordsMatch() {
            return this.input.password == this.helper.confirmPassword
        },
        user() {
            return JSON.parse(localStorage.getItem('user'))
        }
    }
}
</script>

<style>
</style>