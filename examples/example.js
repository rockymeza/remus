//document.write("<h1>This is a heading</h1>");
document.write("<p>This is a paragraph.</p>");
document.write("<p>This is another paragraph.</p>");
/*
multi
line
comment
*/
var RecaptchaOptions = {
      theme : 'custom'
    };
    $(document).ready(function(){
      $("ul,ol").each(function(){
        if ( ! $(this).parent(':first').hasClass("list") && $(this).parent(':first').attr('tagName').toLowerCase() != "li")
        {
          $(this).wrap(unescape('%3Cdiv class="list"%3E%3C/div%3E'));
        }
      });
    });
