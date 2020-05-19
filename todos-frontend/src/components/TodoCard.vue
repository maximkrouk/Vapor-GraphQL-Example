<template>
    <b-card>
        <div style="display: inline">
            <div style="display: inline-block">
                <b-card-title>{{ todo.title }}</b-card-title>
                <b-card-sub-title>Created by {{ username }}</b-card-sub-title>
            </div>
            <b-button @click="remove" size="sm" style="float: right" variant="outline-danger">Remove</b-button>
        </div>
        <hr>
        <b-card-text>
            {{ todo.content }}
        </b-card-text>
  </b-card>
</template>

<script>

export default {
    props: {
        todo: Object
    },
    methods: {
        remove() {
            fetch("http://localhost:8080/todos/" + this.todo.id, {
                method: 'DELETE'
            }).then(() => this.$emit('onRemove'))
        },
        parseJwt(token) {
            var base64Url = token.split('.')[1];
            var base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            var jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));

            return JSON.parse(jsonPayload);
        }
    },
    computed: {
        jwt() {
            return localStorage.getItem('jwt')
        },
        username() {
            return this.parseJwt(this.jwt).username
        }
    }
}
</script>

<style>
</style>