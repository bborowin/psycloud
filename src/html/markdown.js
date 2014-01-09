// Generated by CoffeeScript 1.6.3
(function() {
  var Markdown, html, marked, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  html = require("./html");

  marked = require("marked");

  _ = require('lodash');

  Markdown = (function(_super) {
    __extends(Markdown, _super);

    function Markdown(spec) {
      var _this = this;
      if (spec == null) {
        spec = {};
      }
      Markdown.__super__.constructor.call(this, spec);
      if (_.isString(spec)) {
        this.spec = {};
        this.spec.content = spec;
      }
      if (this.spec.url != null) {
        $.ajax({
          url: this.spec.url,
          success: function(result) {
            _this.spec.content = result;
            return _this.el.append(marked(_this.spec.content));
          },
          error: function(result) {
            return console.log("ajax failure", result);
          }
        });
      } else {
        this.el.append($(marked(this.spec.content)));
      }
      this.el.addClass("markdown");
    }

    return Markdown;

  })(html.HtmlStimulus);

  exports.Markdown = Markdown;

}).call(this);
