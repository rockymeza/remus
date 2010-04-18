$(function() {
  // there's the gallery and the trash
  var $gallery = $('#gallery'), $trash = $('#trash');

  // let the gallery items be draggable
  $('li',$gallery).draggable({
    cancel: 'a.ui-icon',// clicking an icon won't initiate dragging
    revert: 'invalid', // when not dropped, the item will revert back to its initial position
    containment: $('#demo-frame').length ? '#demo-frame' : 'document', // stick to demo-frame if present
    helper: 'clone',
    cursor: 'move'
  });

  // let the trash be droppable, accepting the gallery items
  $trash.droppable({
    accept: '#gallery > li',
    activeClass: 'ui-state-highlight',
    drop: function(ev, ui) {
      deleteImage(ui.draggable);
    }
  });

  // let the gallery be droppable as well, accepting items from the trash
  $gallery.droppable({
    accept: '#trash li',
    activeClass: 'custom-state-active',
    drop: function(ev, ui) {
      recycleImage(ui.draggable);
    }
  });

  // image deletion function
  var recycle_icon = '<a href="link/to/recycle/script/when/we/have/js/off" title="Recycle this image" class="ui-icon ui-icon-refresh">Recycle image</a>';
  function deleteImage($item) {
    $item.fadeOut(function() {
      var $list = $('ul',$trash).length ? $('ul',$trash) : $('<ul class="gallery ui-helper-reset"/>').appendTo($trash);

      $item.find('a.ui-icon-trash').remove();
      $item.append(recycle_icon).appendTo($list).fadeIn(function() {
        $item.animate({ width: '48px' }).find('img').animate({ height: '36px' });
      });
    });
  }

  // image recycle function
  var trash_icon = '<a href="link/to/trash/script/when/we/have/js/off" title="Delete this image" class="ui-icon ui-icon-trash">Delete image</a>';
  function recycleImage($item) {
    $item.fadeOut(function() {
      $item.find('a.ui-icon-refresh').remove();
      $item.css('width','96px').append(trash_icon).find('img').css('height','72px').end().appendTo($gallery).fadeIn();
    });
  }

  // image preview function, demonstrating the ui.dialog used as a modal window
  function viewLargerImage($link) {
    var src = $link.attr('href');
    var title = $link.siblings('img').attr('alt');
    var $modal = $('img[src$="'+src+'"]');

    if ($modal.length) {
      $modal.dialog('open')
    } else {
      var img = $('<img alt="'+title+'" width="384" height="288" style="display:none;padding: 8px;" />')
        .attr('src',src).appendTo('body');
      setTimeout(function() {
        img.dialog({
            title: title,
            width: 400,
            modal: true
          });
      }, 1);
    }
  }

  // resolve the icons behavior with event delegation
  $('ul.gallery > li').click(function(ev) {
    var $item = $(this);
    var $target = $(ev.target);

    if ($target.is('a.ui-icon-trash')) {
      deleteImage($item);
    } else if ($target.is('a.ui-icon-zoomin')) {
      viewLargerImage($target);
    } else if ($target.is('a.ui-icon-refresh')) {
      recycleImage($item);
    }

    return false;
  });
});
