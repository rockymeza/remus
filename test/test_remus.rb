require "test/unit"
require "remus"

class TestRemus < Test::Unit::TestCase
  def test_classify
    assert_equal 'TestClassify', Remus.classify( :test_classify )
    assert_equal 'Html',         Remus.classify( :html )
    assert_equal 'Js',           Remus.classify( :JS )
  end
  
  def test_parse_shebang
    assert_equal 'ruby',         Remus.parse_shebang( '#!/usr/bin/env ruby' )
    assert_equal 'sh',           Remus.parse_shebang( '#!/bin/sh' )
    assert_nil                   Remus.parse_shebang( '<?php echo "Hello World!" ?>' )
  end
end
