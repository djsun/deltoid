require File.expand_path('../spec_helper', __FILE__)

describe '3 documents, 3 <li>, 1 different class' do
  include Unindentable

  def template(x = nil)
    unindent <<-END
      <html>
        <body>
          <p>Begin</p>
          <ul class="list">
            <li>A</li>
            <li#{x ? " #{x}" : ""}>B</li>
            <li>C</li>
          </ul>
          <p>End</p>
        </body>
      </html>
    END
  end

  before do
    docs = [template, template("class='special'"), template]
    @deltoid = Deltoid.new(docs)
  end

  it 'delta should be correct' do
    actual = @deltoid.delta
    actual.length.should == 3
    actual.should include({
      :index   => 0,
      :content => 'B',
      :xpath   => '/html/body/ul/li[2]',
    })
    actual.should include({
      :index   => 1,
      :content => 'B',
      :xpath   => '/html/body/ul/li[2]',
    })
    actual.should include({
      :index   => 2,
      :content => 'B',
      :xpath   => '/html/body/ul/li[2]',
    })
  end

end
