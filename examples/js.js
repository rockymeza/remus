function loadWidget(type)
{
  var widget = $($.jax('/admin/tutorial/widget/' + type + '/')); //get jQuery widget object
  bindWidgetEvents(widget);
  
  return widget;
}


function loadWidgetPreview(widget)
{
  console.log('loadWidgetPreview', widget);
  return $($.jax('/admin/tutorial/widget-preview/' + widget.attr('id').extractId() + '/', $('#'+ widget.attr('id') +' :input').fieldSerialize(), 'post'));
}


function bindWidgetEvents(widget)
{
  widget.data('id', widget.find('input.widget_id').val());
  widget.data('type', widget.find('input.widget_type').val());
  
  widget.find('.delete').click(function(e)
  {
    deleteWidget(widget);
    return false;
  });
  
  widget.find('.minimize').click(function(e)
  {
    widget.data('minimize') ? maximizeWidget(widget) : minimizeWidget(widget);
    return false;
  });
  
  widget.find('.preview').click(function(e)
  {
    widget.data('preview') ? hidePreview(widget) : showPreview(widget);
    return false;
  });
  
  return widget;
}


function deleteWidget(widget)
{
  $.ajax({
    url: '/admin/tutorial/delete-widget/' + widget.data('id') + '/',
    success: function()
      {
        $('#' + widget.attr('id')).remove();
      }
    });
}


function addExcerpt(widget)
{
  
  widget.addClass('minimizedWidget').children('h2').append(' &mdash '+ widget.find('.widgetInput').val().truncateText(16).entitize());
}


function removeExcerpt(widget)
{
  widget.removeClass('minimizedWidget').children('h2').html( widget.children('h2').html().replace(/\s—\s.*$/, '') );
}


function minimizeWidget(widget, effect)
{
  addExcerpt(widget);
  widget.data('minimize', true).children('div.widget_container')[effect ? effect : 'slideUp']();
}


function maximizeWidget(widget, effect)
{
  hidePreview(widget);
  removeExcerpt(widget);
  widget.data('minimize', false).children('div.widget_container')[effect ? effect : 'slideDown']();
}


function showPreview(widget, effect)
{
  minimizeWidget(widget);
  removeExcerpt(widget);
  var html = loadWidgetPreview(widget);
  
  widget.data('preview', true).children('div.widget_preview').html( html )[effect ? effect : 'slideDown']();
  if ( widget.data('type') == 'source-code' )  prettyPrint();
}


function hidePreview(widget, effect)
{
  addExcerpt(widget);
  widget.data('preview', false).children('div.widget_preview')[effect ? effect : 'slideUp']();
}

function setWidgetOrder()
{
  var i = 0;
  $('.widget').each(function(){ $(this).find('.widget_order_by').val( ++i ) });
}

$(document).ready(function()
{
  //|
  //| Bind all Events for pre-existing widgets
  //|
  $('.widget').each(function(index, element)
  {
    bindWidgetEvents($(element));
    minimizeWidget($(element), 'hide');
  });
  
  
  $('.add_widget').click(function(e)
  {
    if ( $(this).val() )
    {
      $('#widgets').append(loadWidget($(this).val()));
    }
  });
  
  $('#widgets').sortable({
      handle: '.widgetHandle',
      items: 'div.widget',
      axis: 'y',
      cursorAt: 'top',
      tolerance: 'pointer',
      opacity: 0.6,
      revert: true,
      forcePlaceholderSize: true,
      placeholder: 'widgetPlaceholder',
      stop: function(event, ui)
        {
          setWidgetOrder();
        }
    });
  
  $('#admin_edit').submit(function() {
    setWidgetOrder();
  });
});
