require File.expand_path('../spec_helper', __FILE__)

describe '3 identical documents' do
  include Unindentable

  def template
    unindent <<-END
      <p class="intro">Introduction...</p>
      <ul class="list">
        <li>A</li>
        <li>B</li>
        <li>C</li>
      </ul>
      <p class="summary">Summary...</p>
    END
  end

  before do
    docs = [template, template, template]
    @deltoid = Deltoid.new(docs)
  end

  it 'delta should be correct' do
    @deltoid.delta.should == []
  end

end
