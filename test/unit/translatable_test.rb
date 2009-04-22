require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::TranslatableTest < ActiveSupport::TestCase

  def test_should_save_translatable_attributes_list
    ar = create_ar
    ar.class_eval do
      translatable :field1, :field2
    end
    assert_equal [:field1, :field2], ar.instance_variable_get('@translatable_attributes')
  end

  def test_should_accumulate_translatable_attributes_list_from_parent
    ar = create_ar
    ar.class_eval do
      translatable :field1, :field2
    end
    son = Class.new(ar)
    son.class_eval do
      translatable :field3, :field4
    end
    assert_equal [:field1, :field2, :field3, :field4], son.instance_variable_get('@translatable_attributes')
    gson = Class.new(son)
    gson.class_eval do
      translatable :field5
    end
    assert_equal [:field1, :field2, :field3, :field4, :field5], gson.instance_variable_get('@translatable_attributes')
  end
  

  def test_should_have_global_translatable_attributes
    ar = create_ar
    assert_equal_set [:locale, :content_id], ar.instance_variable_get('@global_translatable_attributes')
  end
  
  def test_should_add_global_translatable_attribute
    ar = create_ar
    ar.class_eval do
      add_translatable_attributes :attr1, :attr2
    end
    [:attr1, :attr2].each{|attr| assert ar.instance_variable_get('@global_translatable_attributes').include?(attr)}
  end

  def test_should_store_locale
    model = create_model(:field1 => 'ca', :locale => 'ca')
    assert String === model.locale
    assert_equal model.field1, model.locale
  end

  def test_should_store_string_locale_in_dual_format
    locale = create_locale(:iso_code => 'ca')
    model = create_model(:locale => locale)
    assert_equal 'ca', model.locale
  end
  
  def test_should_add_content_id_on_create_if_empty
    assert_difference 'TestModel.count' do
      model = create_model
      assert_not_nil model.content_id
    end  
  end
  
  def test_should_not_add_content_id_on_create_if_exists
    assert_difference 'TestModel.count' do
      model = create_model(:content_id => 12)
      assert_equal 12, model.content_id
    end      
  end

  def test_should_add_current_locale_on_create_if_empty
    assert_difference 'TestModel.count' do
      model = create_model
      assert_equal Locale.current, model.locale
    end  
  end
  
  def test_should_not_add_current_locale_on_create_if_exists
    assert_difference 'TestModel.count' do
      model = create_model(:locale => 'ca')
      assert_equal 'ca', model.locale
    end
  end
  
  def test_should_update_non_translatable_attributes_in_instances_sharing_content_id_on_create
    test_1 = create_model(:field1 => 'f1', :field2 => 'f2', :locale => 'ca')
    test_2 = create_model(:field1 => 'newf1', :field2 => 'newf2', :content_id => test_1.content_id)
    create_model(:field1 => 'newerf1', :field2 => 'newerf2')
    assert_equal 'newf2', test_1.reload.field2
    assert_equal 'f1', test_1.field1
    assert_equal 'newf1', test_2.field1
    assert_equal 'newf2', test_2.field2
  end

  def test_should_update_non_translatable_attributes_in_instances_sharing_content_id_on_update
    test_1 = create_model(:field1 => 'f1', :field2 => 'f2', :locale => 'ca')
    test_2 = create_model(:field1 => 'newf1', :field2 => 'newf2', :content_id => test_1.content_id)
    test_1.update_attribute :field2, 'common'
    assert_equal 'common', test_2.reload.field2
    test_2.update_attribute :field1, 'mine'
    assert_equal 'f1', test_1.reload.field1
  end

  private
    
  def create_ar(options = {})
    Class.new(ActiveRecord::Base)
  end
    
  create_test_model_backend
  
end

