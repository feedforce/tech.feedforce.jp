var FFBLOG = FFBLOG || {};
FFBLOG.Common = {};

FFBLOG.Common.Menu = {
  SET_CLASS_NAME: 'togmenu',
  init : function() {
    this.setParameter();
    this.bindEvent();
  },
  setParameter : function() {
    this.$openTrigger = $('.menubtn');
    this.$menu = $('#menu');
  },
  bindEvent : function() {
    var _self = this;

    this.$openTrigger.on('click', function() {
      _self.$openTrigger.toggleClass(SET_CLASS_NAME)
    })
  }
};

FFBLOG.Common.PageTop = {
  DURANTION: {
    SHOW_HIDE: 200,
    PAGE_TOP: 500
  },
  init : function() {
    this.setParameter();
    this.bindEvent();
  },
  setParameter : function () {
    this.$window = $(window);
    this.$body   = $('html, body')

    this.$pageTopTarget = $('.pagetop');
  },
  bindEvent : function() {
    var _self = this;

    this.$window.on('scroll', function(){
      if ($(this).scrollTop() > 0) {
        _self.$pageTopTarget.stop().animate({
          bottom: '30px'
        },_self.DURANTION.SHOW_HIDE);
      } else {
        _self.$pageTopTarget.stop().animate({
          bottom: '-70px'
        },_self.DURANTION.SHOW_HIDE);
      }
    });

    this.$pageTopTarget.on('click', function(e) {
      e.preventDefault();
      _self.$body.animate({scrollTop: 0}, _self.DURANTION.PAGE_TOP);
    })
  }
};

FFBLOG.Common.PrettyCode = {
  ADD_CLASS_NAME : 'prettyprint',
  init : function() {
    this.bindEvent();
  },
  bindEvent : function() {
    $('html, body').find('pre').addClass(this.ADD_CLASS_NAME);
    prettyPrint();
  }
};

$(function () {
  FFBLOG.Common.Menu.init();
  FFBLOG.Common.PageTop.init();
  FFBLOG.Common.PrettyCode.init();
});

!function (d, i) {
  if (!d.getElementById(i)) {
    var j = d.createElement("script");
    j.id = i;
    j.src = "https://widgets.getpocket.com/v1/j/btn.js?v=1";
    var w = d.getElementById(i);
    d.body.appendChild(j);
  }
}(document, "pocket-btn-js");
