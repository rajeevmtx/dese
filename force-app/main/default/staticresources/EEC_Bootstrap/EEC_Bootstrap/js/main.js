var j$ = jQuery.noConflict();

j$(function(){
  j$('.show-search').click(function(){
   j$('#search-bar').slideToggle();
  });
  
  j$('.show-notifications').on('click', function(){
      j$('.notification-bar').slideToggle();
  });
});

