--links from page--


(function() {
   var head = document.getElementsByTagName("head")[0];
   var script = document.createElement("script");
   script.src = "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js";
   script.onload = function() {
      let lst = "";
      $(".videosGridWrapper a.linkVideoThumb").each(function(i,el){
         el=$(el); 
         console.log(el.attr("href"))
         lst +=  "dl https://www.youtube.com" + el.attr("href") + "\n";
      }); 
      console.log(lst);
   };
   head.appendChild(script);
})();


(function() {
   var head = document.getElementsByTagName("head")[0];
   var script = document.createElement("script");
   script.src = "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js";
   script.onload = function() {
      let lst = "";
      $(".videoUList a.linkVideoThumb").each(function(i,el){
         el=$(el); 
         console.log(el.attr("href"))
         if (!el.data("title").match("franzdoodle")) {
            lst +=  "dl https://www.youtube.com" + el.attr("href") + "\n";
         }
      }); 
      console.log(lst);
   };
   head.appendChild(script);
})();


(function(clas) {
   var head = document.getElementsByTagName("head")[0];
   var script = document.createElement("script");
   script.src = "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js";
   script.onload = function() {
      let lst = "";
      $(`${clas} a.linkVideoThumb`).each(function(i,el){
         el=$(el); 
         console.log(el.attr("href"))
         if (!el.data("title").match("franzdoodle")) {
            lst +=  "dl https://www.youtube.com" + el.attr("href") + "\n";
         }
      }); 
      console.log(lst);
   };
   head.appendChild(script);
})(".video-wrapper");

(function(clas) {
   var head = document.getElementsByTagName("head")[0];
   var script = document.createElement("script");
   script.src = "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js";
   script.onload = function() {
      let lst = "";
      $(`${clas} a.linkVideoThumb`).each(function(i,el){
         el=$(el); 
         console.log(el.attr("href"))
         if (!el.data("title").match("franzdoodle")) {
            lst +=  "dl https://www.youtube.com" + el.attr("href") + "\n";
         }
      }); 
      console.log(lst);
   };
   head.appendChild(script);
})(".videos");


$(`.videos a.linkVideoThumb`).




(function() {
   var head = document.getElementsByTagName("head")[0];
   var script = document.createElement("script");
   script.src = "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js";
   script.onload = function() {
      let lst = "";
      $(".videos a.linkVideoThumb").each(function(i,el){
         el=$(el); 
         console.log(el.attr("href"))
         lst +=  "dl https://www.youtube.com" + el.attr("href") + "\n";
      }); 
      console.log(lst);
   };
   head.appendChild(script);
})();



----------------------------wip-----------------------------
function i() {
  var head = document.getElementsByTagName("head")[0];
  var script = document.createElement("script");
  script.src = "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js";
  script.onload = function() {
    $("p").css("border", "3px solid red");
  };
  head.appendChild(script);
}

function g() {
   let lst = "";
   $("a.linkVideoThumb").each(function(i,el){
      el=$(el); 
      console.log(el.attr("href"))
      lst +=  "dl https://www.youtube.com" + el.attr("href") + "\n";
   }); 
   console.log(lst);
}

// $("a.linkVideoThumb").each(function(i,el){el=$(el); console.log(el.attr("href"))});
function z() {
   var head = document.getElementsByTagName("head")[0];
   var script = document.createElement("script");
   script.src = "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js";
   script.onload = function() {
      let lst = "";
      $("a.linkVideoThumb").each(function(i,el){
         el=$(el); 
         console.log(el.attr("href"))
         lst +=  "dl https://www.youtube.com" + el.attr("href") + "\n";
      }); 
      console.log(lst);
   };
   head.appendChild(script);
}

