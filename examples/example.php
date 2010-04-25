<?php

/**
 * Orderable class: adds selectOrdered and fetchOrdered to query class, using order_by (or other column, if specified)
 * 
 * @author Colin Thomas-Arnold
 * @package Worm
 * @subpackage Behavior
 * @copyright Copyright (c) 2010, Fusionbox, Inc.
 */
class OrderableBehavior extends Behavior
{
  public $orderable_column_name;
  public $order_by_group;
  
  
  public function __construct($table_name, $table_schema, $options)
  {
    // backwards compatibility 'order_by_column_name'
    if ( isset($options['order_by_column_name']) )
    {
      $options['orderable_column_name'] = $options['order_by_column_name'];
      TU::warning('In `'. $table_name .'` OrderableBehavior: "order_by_column_name" is deprecated.  Please use "orderable_column_name"');
    }
    else if ( isset($options['order_by']) )
    {
      $options['orderable_column_name'] = $options['order_by'];
      TU::warning('In `'. $table_name .'` OrderableBehavior: "order_by" is deprecated.  Please use "orderable_column_name"');
    }
    
    parent::__construct($table_name, $table_schema, $options);
    $this->defaultColumn('orderable', 'order_by');
    $this->defaultValue('order_by_group', NULL);
    $this->defaultValue('order_by_group_label', NULL);
    $this->defaultValue('order_by_group_label_default', NULL);
  }
  
  
  /**
   * called from ModelGenerator::prepareTable, so column translation has not yet occurred.
   */
  public function modifySchema($table_name, &$table_schema, $model_generator)
  {
    $this->dontMerge($this->orderable_column_name, $table_schema);
    
    if ( ! isset($table_schema['columns'][$this->orderable_column_name]) )
    {
      $table_schema['columns'][$this->orderable_column_name] = array(
        'type' => 'int',
        'sql_type' => 'tinyint',
        'sql_options' => array('unsigned' => TRUE),
        'sql_index' => 'index',
        'editable' => FALSE,
        );
    }
    
    # // this code doesn't seem right - how can orderable assume the type / sql_type of the order_by_group?
    #if ( $this->order_by_group && ! isset($table_schema['columns'][$this->order_by_group]) )
    #{
    #  $table_schema['columns'][$this->order_by_group] = array(
    #    'type' => 'int',
    #    'sql_type' => 'int',
    #    'sql_options' => array('unsigned' => TRUE),
    #    'sql_index' => 'index',
    #    'editable' => FALSE,
    #    );
    #}
    
    $continue = TRUE;
    if ( $table_schema['order_by'] )
    {
      TU::puts('OrderableBehavior: Table `'. $table_name .'` has order_by set to "'. TU::print_r($table_schema['order_by']) .'".');
      $continue = TU::confirm('Can I overwrite that?');
    }
    
    if ( $continue )
    {
      array_unshift($table_schema['order_by'], '`'. $this->table_name .'`.`'. $this->orderable_column_name .'` ASC');
      if ( $this->order_by_group )
      {
        array_unshift($table_schema['order_by'], '`'. $this->table_name .'`.`'. $this->order_by_group .'` ASC');
      }
    }
  }
  
  
  public function Query_addMethods()
  {
    $class_name = $this->table_schema['cc_name'];
    $query_class = $this->table_schema['query_class'];
    $column_name = $this->orderable_column_name;
    
    SU::puts(
      'static public function selectOrdered($columns = NULL)',
      '{',
      '  if ( func_num_args() > 1 )',
      '  {',
      '    $columns = func_get_args();',
      '  }',
      '  else if ( $columns !== NULL )',
      '  {',
      '    $columns = (is_array($columns) ? $columns : array($columns));',
      '  }',
      '  return '. $query_class .'::select($columns)->ordered();',
      '}',
      '',
      '',
      'public function ordered()',
      '{',
      '  $this->orderBy(\''. ($this->order_by_group ? '`'. $this->table_name .'`.`'. $this->order_by_group .'` ASC, ' : '') .'`'. $this->table_name .'`.`'. $this->orderable_column_name .'` ASC\');',
      '  return $this;',
      '}',
      '',
      '',
      'public function fetchOrdered()',
      '{',
      '  $results = $this->fetchAll();',
      '  $sorted = array();'
      );
    if ( $this->order_by_group )
    {
      SU::puts(
      '  $grouped = array();',
      '  foreach($results as $obj)',
      '  {',
      '    $group = (int)$obj->get(\''. $this->order_by_group .'\');',
      '    $grouped[$group][$obj->get(\''. $this->orderable_column_name .'\')] = $obj;',
      '  }',
      '  ksort($grouped, SORT_NUMERIC);',
      '  foreach($grouped as $group => $data)',
      '  {',
      '    ksort($data, SORT_NUMERIC);',
      '    $sorted = array_merge($sorted, $data);',
      '  }'
      );
    }
    else
    {
      SU::puts(
      '  foreach($results as $obj)',
      '  {',
      '    $sorted[$obj->get(\''. $this->orderable_column_name .'\')] = $obj;',
      '  }',
      '  ksort($sorted, SORT_NUMERIC);'
      );
    }
    SU::puts(
      '  return $sorted;',
      '}'
      );
    
    if ( count($this->primary_keys) == 1)
    {
      $pk = $this->primary_keys[0];
      SU::puts(
      '',
      '',
      'static public function reorderAll()',
      '{'
      );
      if ( $this->order_by_group )
      {
        SU::puts(
      '  $rows = Query::fetchAll(\'SELECT `'. $pk .'`, `'. $this->orderable_column_name .'`, `'. $this->order_by_group .'` FROM `'. $this->table_name .'` ORDER BY `'. $this->order_by_group .'`, `'. $this->orderable_column_name .'`\');',
      '  $index = 1;',
      '  $group_by = NULL;',
      '  foreach($rows as $row)',
      '  {',
      '    if ( $row[\''. $this->order_by_group .'\'] != $group_by )',
      '    {',
      '      $index = 1;',
      '      $group_by = $row[\''. $this->order_by_group .'\'];',
      '    }',
      '    Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = ? WHERE `'. $pk .'` = ? LIMIT 1\', $index, $row[\''. $pk .'\']);',
      '    ++$index;',
      '  }'
        );
      }
      else
      {
        SU::puts(
      '  $rows = Query::fetchAll(\'SELECT `'. $pk .'`, `'. $this->orderable_column_name .'` FROM `'. $this->table_name .'` ORDER BY ``\');',
      '  $index = 1;',
      '  foreach($rows as $row)',
      '  {',
      '    Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = ? WHERE `'. $pk .'` = ? LIMIT 1\', $index, $row[\''. $pk .'\']);',
      '    ++$index;',
      '  }'
        );
      }
      SU::puts(
      '}'
        );
    }
    else
    {
      TU::warning('OrderableBehavior::reorderAll not available on tables with multiple primary keys.');
    }
  }
  
  
  public function Model_addMethods()
  {
    $class_name = $this->table_schema['cc_name'];
    $query_class = $this->table_schema['query_class'];
    $column_name = $this->orderable_column_name;
    
    $pk_where = '';
    foreach($this->primary_keys as $pk)
    {
      if ($pk_where)  $pk_where .= ' AND ';
      $pk_where .= '`'. $pk .'` = ?';
    }
    
    $not_pk_where = '';
    foreach($this->primary_keys as $pk)
    {
      if ($not_pk_where)  $not_pk_where .= ' AND ';
      $not_pk_where .= '`'. $pk .'` <> ?';
    }
    
    $pk_value = '';
    foreach($this->primary_keys as $pk)
    {
      if ($pk_value)  $pk_value .= ', ';
      $pk_value .= '$this->_columns[\''. $pk .'\']';
    }
    
    SU::puts(
      'public function orderByGroup()',
      '{',
      '  return '. ($this->order_by_group ? '\''. $this->order_by_group .'\'' : 'NULL') .';',
      '}',
      '',
      '',
      'public function moveUp()',
      '{',
      '  $order_by_group = $this->orderByGroup();',
      '  $old_order = $this->get(\''. $this->orderable_column_name .'\');',
      '  $new_order = $this->get(\''. $this->orderable_column_name .'\');',
      '  ',
      '  if ( $order_by_group )  $new_query = '. $query_class .'::selectBy($order_by_group, $this->get($order_by_group));',
      '  else  $new_query = '. $query_class .'::select();',
      '  $new_query->andWhere(\'`'. $this->orderable_column_name .'` < ?\', $old_order)',
      '    ->orderBy(\''. $this->orderable_column_name .' DESC\')',
      '    ->limit(1);',
      '  $new_obj = $new_query->fetchOne();',
      '  ',
      '  if ( $new_obj )',
      '  {',
      '    $new_order = $new_obj->get(\''. $this->orderable_column_name .'\');',
      '    $new_obj->set(\''. $this->orderable_column_name .'\', $old_order);',
      '    $new_obj->save(\''. $this->orderable_column_name .'\');',
      '    $this->set(\''. $this->orderable_column_name .'\', $new_order);',
      '    $this->save(\''. $this->orderable_column_name .'\');',
      '  }',
      '}',
      '',
      '',
      'public function moveDown()',
      '{',
      '  $order_by_group = $this->orderByGroup();',
      '  $old_order = $this->get(\''. $this->orderable_column_name .'\');',
      '  $new_order = $this->get(\''. $this->orderable_column_name .'\');',
      '  ',
      '  if ( $order_by_group )  $new_query = '. $query_class .'::selectBy($order_by_group, $this->get($order_by_group));',
      '  else  $new_query = '. $query_class .'::select();',
      '  $new_query->andWhere(\'`'. $this->orderable_column_name .'` > ?\', $old_order)',
      '    ->orderBy(\''. $this->orderable_column_name .' ASC\')',
      '    ->limit(1);',
      '  $new_obj = $new_query->fetchOne();',
      '  ',
      '  if ( $new_obj )',
      '  {',
      '    $new_order = $new_obj->get(\''. $this->orderable_column_name .'\');',
      '    $new_obj->set(\''. $this->orderable_column_name .'\', $old_order);',
      '    $new_obj->save(\''. $this->orderable_column_name .'\');',
      '    $this->set(\''. $this->orderable_column_name .'\', $new_order);',
      '    $this->save(\''. $this->orderable_column_name .'\');',
      '  }',
      '}',
      '',
      '',
      'public function moveTo($index)',
      '{',
      '  $order_by_group = $this->orderByGroup();',
      '  $min_query = '. $query_class .'::select(\'MIN(`order_by`)\');',
      '  $max_query = '. $query_class .'::select(\'MAX(`order_by`)\');',
      '  if ( $order_by_group )',
      '  {',
      '    $min_query->whereEquals($order_by_group, $this->get($order_by_group));',
      '    $max_query->whereEquals($order_by_group, $this->get($order_by_group));',
      '  }',
      '  $min = $min_query->fetchOnly();',
      '  $max = $max_query->fetchOnly();',
      '  $index = max(min($index, $max), $min);',
      '  if ( $index != $this->get(\''. $this->orderable_column_name .'\') )',
      '  {',
      '    $old_pos = $this->get(\''. $this->orderable_column_name .'\');',
      '    $new_pos = intval($index);',
      '    if ( $new_pos < $old_pos )', // moving up, eg 5 => 2: (1,2,4,5,6) 1=>1, 2=>3, 4=>5, 5=>2, 6=>6 (1,3,5,2,6)
      '    {',
      '      if ( is_null($order_by_group) )',
      '      {',
      '        Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` + 1 WHERE `'. $this->orderable_column_name .'` >= ? AND `'. $this->orderable_column_name .'` < ?\', $new_pos, $old_pos);',
      '      }',
      '      else if ( is_null($this->get($order_by_group)) )',
      '      {',
      '        Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` + 1 WHERE `\'. $order_by_group .\'` IS NULL AND `'. $this->orderable_column_name .'` >= ? AND `'. $this->orderable_column_name .'` < ?\', $new_pos, $old_pos);',
      '      }',
      '      else',
      '      {',
      '        Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` + 1 WHERE `\'. $order_by_group .\'` = ? AND `'. $this->orderable_column_name .'` >= ? AND `'. $this->orderable_column_name .'` < ?\', $this->get($order_by_group), $new_pos, $old_pos);',
      '      }',
      '    }',
      '    else', // moving up, eg 2 => 5: (1,2,4,5,6) 1=>1, 2=>5, 4=>3, 5=>4, 6=>6 (1,5,3,4,6)
      '    {',
      '      if ( is_null($order_by_group) )',
      '      {',
      '        Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` - 1 WHERE `'. $this->orderable_column_name .'` <= ? AND `'. $this->orderable_column_name .'` > ?\', $new_pos, $old_pos);',
      '      }',
      '      else if ( is_null($this->get($order_by_group)) )',
      '      {',
      '        Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` - 1 WHERE `\'. $order_by_group .\'` IS NULL AND `'. $this->orderable_column_name .'` <= ? AND `'. $this->orderable_column_name .'` > ?\', $new_pos, $old_pos);',
      '      }',
      '      else',
      '      {',
      '        Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` - 1 WHERE `\'. $order_by_group .\'` = ? AND `'. $this->orderable_column_name .'` <= ? AND `'. $this->orderable_column_name .'` > ?\', $this->get($order_by_group), $new_pos, $old_pos);',
      '      }',
      '    }',
      '    $this->set(\''. $this->orderable_column_name .'\', $new_pos);',
      '    $this->save();',
      '  }',
      '}',
      '',
      '',
      'public function calculateOrderBy()',
      '{',
      '  $order_by_group = $this->orderByGroup();',
      '  if ( is_null($order_by_group) )',
      '  {',
      '    $order_by = Query::fetchOnly(\'SELECT MAX(`order_by`) + 1 FROM `'. $this->table_name .'`\');',
      '  }',
      '  else if ( is_null($this->get(\'\'. $order_by_group .\'\')) )',
      '  {',
      '    $order_by = Query::fetchOnly(\'SELECT MAX(`'. $this->orderable_column_name .'`) + 1 FROM `'. $this->table_name .'` WHERE `\'. $order_by_group .\'` IS NULL\');',
      '  }',
      '  else',
      '  {',
      '    $order_by = Query::fetchOnly(\'SELECT MAX(`'. $this->orderable_column_name .'`) + 1 FROM `'. $this->table_name .'` WHERE `\'. $order_by_group .\'` = ?\', $this->get(\'\'. $order_by_group .\'\'));',
      '  }',
      '  return is_null($order_by) ? 1 : $order_by;',
      '}',
      '',
      '',
      'public function ensureOrderBy($order_by)',
      '{',
      '  $order_by_group = $this->orderByGroup();',
      '  if ( is_null($order_by_group) )',
      '  {',
      '    while ( Query::fetchOne(\'SELECT 1 FROM `'. $this->table_name .'` WHERE '. $not_pk_where .' AND `'. $this->orderable_column_name .'` = ? LIMIT 1\', '. $pk_value .', $order_by) )',
      '    {',
      '      ++$order_by;',
      '      $this->_columns[\''. $this->orderable_column_name .'\'] = $order_by;',
      '      Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = ? WHERE '. $pk_where .'\', $order_by, '. $pk_value .');',
      '    }',
      '  }',
      '  else',
      '  {',
      '    while ( Query::select(1)->from(\'`'. $this->table_name .'`\')',
      '          ->whereEquals(\'`'. $this->table_name .'`.`\'. $order_by_group .\'`\', $this->get($order_by_group))',
      '          ->where(\''. $not_pk_where .' AND `'. $this->orderable_column_name .'` = ?\', '. $pk_value .', $order_by)',
      '          ->limit(1)',
      '          ->fetchOne() )',
      '    {',
      '      ++$order_by;',
      '      $this->_columns[\''. $this->orderable_column_name .'\'] = $order_by;',
      '      Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = ? WHERE '. $pk_where .'\', $order_by, '. $pk_value .');',
      '    }',
      '  }',
      '}',
      '',
      '',
      'public function removeOrderBy()',
      '{',
      '  $order_by_group = $this->orderByGroup();',
      '  if ( is_null($order_by_group) )',
      '  {',
      '    Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` - 1 WHERE `'. $this->orderable_column_name .'` > ?\', $this->get(\''. $this->orderable_column_name .'\'));',
      '  }',
      '  else if ( is_null($this->get($order_by_group)) )',
      '  {',
      '    Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` - 1 WHERE `'. $this->orderable_column_name .'` > ? AND `\'. $order_by_group .\'` IS NULL\', $this->get(\''. $this->orderable_column_name .'\'));',
      '  }',
      '  else',
      '  {',
      '    Query::execute(\'UPDATE `'. $this->table_name .'` SET `'. $this->orderable_column_name .'` = `'. $this->orderable_column_name .'` - 1 WHERE `'. $this->orderable_column_name .'` > ? AND `\'. $order_by_group .\'` = ?\', $this->get(\''. $this->orderable_column_name .'\'), $this->get($order_by_group));',
      '  }',
      '}'
      );
  }
  
  
  public function Model_willInsert()
  {
    SU::puts(
      'if ( ! $insert_stmt->containsColumn(\''. $this->orderable_column_name .'\') )',
      '{',
      '  $order_by = $this->calculateOrderBy();',
      '  $this->set(\''. $this->orderable_column_name .'\', $order_by);',
      '  $insert_stmt->addColumn(\''. $this->orderable_column_name .'\');',
      '  $insert_stmt->addValue($this->_columns[\''. $this->orderable_column_name .'\']);',
      '}',
      'else if ( $this->_columns[\''. $this->orderable_column_name .'\'] )',
      '{',
      '  $order_by = $this->_columns[\''. $this->orderable_column_name .'\'];',
      '}',
      'else',
      '{',
      '  throw Worm::exception(\'In '. SU::camelCase($this->table_name) .'::save(), invalid value for column '. $this->orderable_column_name .'\');',
      '}'
      );
  }
  
  
  public function Model_didInsert()
  {
    SU::puts('$this->ensureOrderBy($order_by);');
  }
  
  
  public function Model_didDestroy()
  {
    if ( $this->extended )  return;
    
    SU::puts('$this->removeOrderBy();');
  }
  
  
  public function Admin_browseHeader()
  {
    SU::puts('      <th>Order</th>');
  }
  
  
  public function Admin_browseColumn()
  {
    $title = $this->table_schema['display_name'];
    SU::puts(
      '<td>',
      '  <input type="text" class="order_by_input" size="3" value="<?php echo $data_obj->get(\''. $this->orderable_column_name .'\'); ?>" />'
      );
    if ( $this->order_by_group )
    {
      $order_by_group_label = ($this->order_by_group_label ? $this->order_by_group_label : $this->order_by_group);
      SU::out('  <input type="hidden" class="order_by_group" value="<?php echo WU::entitize($data_obj->fetch(\''. $order_by_group_label .'\')'. ($this->order_by_group_label_default ? ' ? $data_obj->fetch(\''. $order_by_group_label .'\') : '. Task::toPhp($this->order_by_group_label_default) : ''));
      
      if ( SU::endsWith($this->order_by_group, '_id') )
      {
        // add link:
        SU::out('. \' &rdquo; <a href="/admin/'. $this->controller_name .'/edit/?'. $this->name .'%5B'. $this->order_by_group .'%5D=\'. $data_obj->get(\''. $this->order_by_group .'\') .\'">Add '. $title .'</a>\'');
      }
      SU::puts('); ?>" />');
    }
    SU::puts(
      '</td>'
      );
  }
  
  
  public function Admin_rowActions()
  {
    SU::puts(
      '<a class="action" href="/admin/'. $this->controller_name .'/move-up/<?php echo $data_obj->get(\'id\'); ?>/?page=<?php echo $this->request[\'id\']; ?>">Move&nbsp;up</a>',
      '<a class="action" href="/admin/'. $this->controller_name .'/move-down/<?php echo $data_obj->get(\'id\'); ?>/?page=<?php echo $this->request[\'id\']; ?>">Move&nbsp;down</a>'
      );
  }
  
  
  public function Admin_browseJs()
  {
    SU::puts(
'  $(document).ready(function()
    {

    $("input.order_by_input").bind("focus", function()
    {
      $("input.to_be_re_ordered").remove();
      $(this).after(\'<input class="to_be_re_ordered" type="hidden" name="reorder" value="\' + $(this).val() + \'" />\');
    });

    $("input.order_by_input").bind("keyup", function(event)
      {
        if ( event.keyCode == 13 )
        {
          reorder($(this));
        }
      });

    $("input.order_by_input").bind("blur", function(event)
      {
        reorder($(this));
      });
');

  if ( $this->order_by_group )
  {
SU::puts(
'    var old_order_by_group;
    $(\'.order_by_group\').each(function()
      {
        if ( typeof old_order_by_group == \'undefined\' || old_order_by_group != $(this).val() )
        {
          old_order_by_group = $(this).val();
          parent = $(this).parent().parent()
          colspan = parent.children().length
          parent.before(\'<tr class="separator"><td colspan="\' + colspan + \'">\' + $(this).val() + \'</td></tr>\');
        }
      });');
  }
SU::puts(
'    function reorder(input)
    {
      var url = \'/admin/'. $this->controller_name .'/re-order/\' + input.parent().prev().find("input").val() + \'/?page=\' + (fbmvc.Id ? fbmvc.Id : \'\');
      var reorder_id = input.val();

      jQuery.post(url, { reorder: reorder_id }, function() { 
          window.location = \'/admin/'. $this->controller_name .'/browse/\' + (fbmvc.Id ? fbmvc.Id + \'/\' : \'\');
      });
    }


  });');
  
  }
  
  
  public function Controller_addMethods()
  {
    $class_name = $this->table_schema['cc_name'];
    $table_disp_name = $this->table_schema['display_name'];
    
    $code = <<<PHP
public function executeReOrder()
{
  self::requireAjax();
  self::requireId();
  
  if ( ! is_null(\$this->request['reorder']) )
  {
    \$data_obj = \$this->getDataObj();
    if ( \$data_obj )
    {
      \$data_obj->moveTo(\$this->request['reorder']);
    }
  }

  MVC::end();
}


public function executeMoveUp()
{
  \$data_obj = \$this->getDataObj();
  \$old_order = \$data_obj->get('{$this->orderable_column_name}');
  \$data_obj->moveUp();
  \$new_order = \$data_obj->get('{$this->orderable_column_name}');
  
  if ( \$old_order == \$new_order )
  {
    \$this->flash['message'] = 'That {$table_disp_name} is already the first item.';
  }
  
  WU::redirect('/admin/{$this->controller_name}/browse/'. (\$this->request['page'] ? \$this->request['page'] .'/' : ''));
}


public function executeMoveDown()
{
  \$data_obj = \$this->getDataObj();
  \$old_order = \$data_obj->get('{$this->orderable_column_name}');
  \$data_obj->moveDown();
  \$new_order = \$data_obj->get('{$this->orderable_column_name}');
  
  if ( \$old_order == \$new_order )
  {
    \$this->flash['message'] = 'That {$table_disp_name} is already the last item.';
  }
  
  WU::redirect('/admin/{$this->controller_name}/browse/'. (\$this->request['page'] ? \$this->request['page'] .'/' : ''));
}
PHP;
    SU::puts(explode("\n", $code));
  }
  
  
  static public function generateSchema($table_name, $table_schema)
  {
    if ( TU::confirm('`'. $table_name .'`.order_by is an orderable column? ') )
    {
      $order_by_group = NULL;
      if ( isset($table_schema['columns']['group']) )
      {
        $order_by_group = 'group';
      }
      else if ( isset($table_schema['columns']['group_by']) )
      {
        $order_by_group = 'group_by';
      }
      
      if ( $order_by_group )
      {
        $order_by_group = (TU::gets('`'. $table_name .'`.order_by is grouped by `'. $order_by_group .'`? ', 'yn', 'y') ? $order_by_group : NULL);
      }
      
      if ( ! $order_by_group )
      {
        $order_by_group = TU::gets('If `'. $table_name .'`.order_by is grouped, what is the column name? [Enter for no grouping] ');
      }
      
      $table_schema['act_as']['orderable'] = ($order_by_group ? array('order_by_group' => $order_by_group) : array());
      unset($table_schema['columns']['order_by']);
    }
    return $table_schema;
  }
  
  
}
