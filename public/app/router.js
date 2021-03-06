define([
  // Application.
  "app",
  "modules/jobs",
  "modules/articles",
  "modules/reports"
],

function(app, Job, Article, Report) {

  // Defining the application router, you can attach sub routers here.
  var Router = Backbone.Router.extend({
    routes: {
      "": "index"
    },

    initialize : function() {
      app.joblist = new Job.Collection();
      app.joblist.fetch().then(function() {
        console.log(app.joblist);
      });
    },


    index: function() {
      var j = new Job.Model();

      app.useLayout('main-layout').setViews({
        ".job_form" : new Job.Views.Form({ model : j }, { job_list: app.joblist }),
        ".job_list" : new Job.Views.List({ collection : app.joblist }),
        ".main_ui"  : new Report.Views.Main()
      }).render();
    }

  });

  return Router;

});
