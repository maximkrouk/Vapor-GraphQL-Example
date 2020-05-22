<template>
  <div style="display: inline">
    <b-button class="mr-2" size="sm" variant="light" v-b-modal.modal-prevent-closing>Add</b-button>
    <b-modal
      id="modal-prevent-closing"
      ref="modal"
      title="New todo"
      centered
      @show="resetModal"
      @hidden="resetModal"
      @ok="handleOk"
    >
      <form ref="form" @submit.stop.prevent="handleSubmit">
        <b-form-group
          :state="nameState"
          label-for="name-input"
          invalid-feedback="Title is required"
        >
          <b-form-input
            id="name-input"
            placeholder="Title"
            v-model="name"
            :state="nameState"
            required
          ></b-form-input>
        </b-form-group>
        <b-form-textarea
        id="comment-input"
        placeholder="Comment"
        rows="3"
        max-rows="8"
        v-model="comment"
        no-auto-shrink
      ></b-form-textarea>
      </form>
    </b-modal>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        name: '',
        comment: '',
        nameState: null,
      }
    },
    methods: {
      checkFormValidity() {
        const valid = this.$refs.form.checkValidity()
        this.nameState = valid
        return valid
      },
      resetModal() {
        this.name = ''
        this.nameState = null
      },
      handleOk(bvModalEvt) {
        // Prevent modal from closing
        bvModalEvt.preventDefault()
        // Trigger submit handler
        this.handleSubmit()
      },
      handleSubmit() {
        // Exit when the form isn't valid
        if (!this.checkFormValidity()) {
          return
        }
        
        var input = {
          title: this.name,
          content: this.comment
        }

        this.$emit('addItem', input)
        
        // Hide the modal manually
        this.$nextTick(() => {
          this.$bvModal.hide('modal-prevent-closing')
        })
      }
    },
    computed: {
      jwt() {
        return localStorage.getItem('jwt')
      }
    }
  }
</script>