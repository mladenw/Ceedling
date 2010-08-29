require 'rubygems'
require 'rake' # for ext()


class TestInvokerHelper

  constructor :configurator, :task_invoker, :dependinator, :test_includes_extractor, :file_finder, :file_path_utils, :file_wrapper, :rake_wrapper

  def clean_results(results, options)
    @file_wrapper.rm_f( results[:fail] )
    @file_wrapper.rm_f( results[:pass] ) if (options[:force_run])
  end

  def preprocessing_setup_for_runner(runner)
    return if (not @configurator.project_use_test_preprocessor)

    @rake_wrapper.create_file_task(
      runner,
      @file_path_utils.form_preprocessed_file_filepath( @file_path_utils.form_test_filepath_from_runner(runner) ))
  end

  def process_auxiliary_dependencies(files)
    return if (not @configurator.project_use_auxiliary_dependencies)

    dependencies_list = @file_path_utils.form_test_dependencies_filelist( files )
    @task_invoker.invoke_test_dependencies_files( dependencies_list )
    @dependinator.load_test_object_deep_dependencies( dependencies_list )
  end
  
  def extract_sources(test)
    sources  = []
    includes = @test_includes_extractor.lookup_includes_list(test)
    
    includes.each { |include| sources << @file_finder.find_source_file(include, {:should_complain => false}) }
    
    return sources.compact
  end
  
end
