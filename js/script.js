var FF_BLOG=FF_BLOG||{};FF_BLOG.Common={},FF_BLOG.Common.Menu={SET_CLASS_NAME:"togmenu",init:function(){this.setParameter(),this.bindEvent()},setParameter:function(){this.$openTrigger=$(".menubtn"),this.$menu=$("#menu")},bindEvent:function(){var t=this;this.$openTrigger.on("click",function(){t.$menu.toggleClass(t.SET_CLASS_NAME)})}},FF_BLOG.Common.PageTop={DURATION:{SHOW_HIDE:200,PAGE_TOP:500},VISIBLE_POSITION:700,init:function(){this.setParameter(),this.bindEvent()},setParameter:function(){this.$window=$(window),this.$body=$("html, body"),this.$pageTopTarget=$(".pagetop")},bindEvent:function(){var t=this;this.$window.on("scroll",function(){t.$body.is(":animated")||t.$pageTopTarget.is(":animated")||($(this).scrollTop()>t.VISIBLE_POSITION?t.showPageTopTarget():t.hidePageTopTarget())}),this.$pageTopTarget.on("click",function(e){e.preventDefault(),t.$body.animate({scrollTop:0},t.DURATION.PAGE_TOP,"swing",t.hidePageTopTarget())})},hidePageTopTarget:function(){this.$pageTopTarget.animate({bottom:"-70px"},this.DURATION.SHOW_HIDE)},showPageTopTarget:function(){this.$pageTopTarget.animate({bottom:"30px"},this.DURATION.SHOW_HIDE)}},$(function(){FF_BLOG.Common.Menu.init(),FF_BLOG.Common.PageTop.init()}),!function(t,e){if(!t.getElementById(e)){var n=t.createElement("script");n.id=e,n.src="https://widgets.getpocket.com/v1/j/btn.js?v=1";t.getElementById(e);t.body.appendChild(n)}}(document,"pocket-btn-js");