require File.expand_path('../spec_helper', __FILE__)

describe '3 documents, 3 <li>, 1 different <li>' do
  include Unindentable

  def template(x)
    unindent <<-END
      <html>
        <body>
          <p class="begin">Begin</p>
          <ul class="list">
            <li>A</li>
            <li>B</li>
            <li>#{x}</li>
          </ul>
          <p class="end">End</p>
        </body>
      </html>
    END
  end

  before do
    docs = [template('X'), template('Y'), template('Z')]
    @deltoid = Deltoid.new(docs)
  end

  it 'delta should be correct' do
    actual = @deltoid.delta
    actual.length.should == 3
    actual.should include({
      :index   => 0,
      :content => 'X',
      :xpath   => '/html/body/ul/li[3]',
    })
    actual.should include({
      :index   => 1,
      :content => 'Y',
      :xpath   => '/html/body/ul/li[3]',
    })
    actual.should include({
      :index   => 2,
      :content => 'Z',
      :xpath   => '/html/body/ul/li[3]',
    })
  end

end
