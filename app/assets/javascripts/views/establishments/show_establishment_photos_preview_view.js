EstablishmentShowPhotosPreviewView = Backbone.View.extend({
    events: {
    },

    initialize: function () {
        this.listenTo(this.collection, 'reset', this.render);
        this.listenTo(this.collection, 'add', this.render);
        this.collection.fetch({ reset: true, data: { establishment_id: this.model.get('id') }});
    },

    render: function () {
        this.$el.html('');  

        this.collection.each(function (photo) {
            this.renderPhoto(photo);
        }, this);   
    },

    renderPhoto: function (photo) {
        var photo_view = new PhotoPreviewPhotoView({
            tagName: 'div',
            model: photo
        });

        this.$el.append(photo_view.el);
    }
});