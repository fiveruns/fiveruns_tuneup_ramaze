Fiveruns::Tuneup::Superlative.on Ramaze::Action, :instances do
  
  def uncached_render(*args, &block)
    @_fiveruns_tuneup_uncached_render = true
    Fiveruns::Tuneup.step("Uncached render (#{engine})", :view) { super }
  end

  def cached_render(*args, &block)
    Fiveruns::Tuneup.step("Cached render", :view) { super }
  end
  
  def render(*args, &block)
    result = nil
    tuneup = Fiveruns::Tuneup.record do
      result = Fiveruns::Tuneup.step "Handling #{method}", :controller do
        super
      end
    end
    if Ramaze::Response.current.headers['Location']
      Ramaze::Log.dev 'TuneUp: Ignoring redirect.'
      tuneup = nil
    elsif Ramaze::Request.current.xhr?
      Ramaze::Log.dev 'TuneUp: Ignoring XHR request.'
      tuneup = nil
    elsif controller == FiverunsTuneupController
      Ramaze::Log.dev 'TuneUp: Ignoring internal request.'
      tuneup = nil
    else
      Ramaze::Log.dev 'TuneUp: Valid request.'
    end
    if tuneup
      unless @_fiveruns_tuneup_uncached_render
        result.sub!(/\s*<!-- FIVERUNS_TUNEUP:START -->.*<!-- FIVERUNS_TUNEUP:END -->\s*/s, '')
      end
      run = Fiveruns::Tuneup::Run.new(path, tuneup)
      run.save
      Fiveruns::Tuneup.insert_panel(result, run, false)
    end
  end
end
