$(function () {
  $(".menubtn").click(function () {
    $("#menu").toggleClass('togmenu');
  });

  var flag = false;
  var pagetop = $('.pagetop');
  $(window).scroll(function () {
    if ($(this).scrollTop() > 700) {
      if (flag == false) {
        flag = true;
        pagetop.stop().animate({
          'bottom': '30px'
        }, 200);
      }
    } else {
      if (flag) {
        flag = false;
        pagetop.stop().animate({
          'bottom': '-70px'
        }, 200);
      }
    }
  });
  pagetop.click(function () {
    $('body, html').animate({scrollTop: 0}, 500);
    return false;
  });

  $('pre').addClass('prettyprint');
  // $('pre').addClass('linenums');
  prettyPrint();

  !function (d, i) {
    if (!d.getElementById(i)) {
      var j = d.createElement("script");
      j.id = i;
      j.src = "https://widgets.getpocket.com/v1/j/btn.js?v=1";
      var w = d.getElementById(i);
      d.body.appendChild(j);
    }
  }(document, "pocket-btn-js");
});
