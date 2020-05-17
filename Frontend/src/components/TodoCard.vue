<template>
    <b-card>
        <div style="display: inline">
            <div style="display: inline-block">
                <b-card-title>{{ todo.title }}</b-card-title>
                <b-card-sub-title>Created by {{ user.username }}</b-card-sub-title>
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
        }
    },
    computed: {
         user() {
            return JSON.parse(localStorage.getItem('user'))
        }
    }
}
</script>

<style>
</style>