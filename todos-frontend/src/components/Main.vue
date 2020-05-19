<template>
    <div v-if="jwt != null">
        <b-navbar toggleable="lg" type="dark" variant="dark" sticky>
            <b-navbar-brand tag="h1" class="mb-0">Todos</b-navbar-brand>

            <div>
                <AddTodoVue v-on:onAdded="load"/>
                <b-button @click="load" variant="light" class="mr-2" size="sm" style="display: inline">Refresh</b-button>
                <b-button size="sm" variant="danger" @click="logout">Logout</b-button>
            </div>
        </b-navbar>

        <b-container class="d-flex align-items-top justify-content-center h-100">
            <div class="d-flex flex-column w-100">
                <TodoCardVue :todo="todo" v-on:onRemove="load" class="w-100 mt-3" v-for="(todo) in todos" v-bind:key="todo.id"/>
            </div>
        </b-container>
    </div>
</template>

<script>
import TodoCardVue from './TodoCard.vue'
import AddTodoVue from './AddTodo.vue'
import axios from 'axios'

export default {
    data() {
        return {
            newTitle: "",
            todos: []
        }
    },
    mounted() {
        console.log('mounted')
        this.load()
    },
    methods: {
        add() {
            axios
            .post('http://localhost:8080/todos', {
                headers: {
                    "Authorization": "Bearer " + this.jwt
                }
            })
            .then(response => console.log(response));
        },
        load() {
            axios
            .get('http://localhost:8080/todos', {
                headers: {
                    "Authorization": "Bearer " + this.jwt
                }
            })
            .then(object => { 
                this.todos = JSON.parse(object.request.response)
            });
        },
        logout() {
            localStorage.removeItem('jwt')
            this.$emit('onLogout')
        }
    },
    components: {
        AddTodoVue,
        TodoCardVue
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