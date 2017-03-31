def __main__(argv)
  opts = Getopts.getopts(
    'r:t:v',
    'repository',
    'type',
    'version'
  )

  if opts.include?('v') || opts.include?('version')
    puts "release-note:#{ReleaseNote::VERSION}"
  else
    repo = opts['r'] || 'nasum/release-note'

    type = if opts['t'] == 'issue'
      'issues'
    elsif opts['t'] == 'pull-request'
      'pulls'
    else
      'issues'
    end

    curl = Curl.new

    headers = {
      'User-Agent' => 'release-note'
    }

    url = "https://api.github.com/repos/#{repo}/#{type}?access_token=#{ENV['GITHUB_ACCESS_TOKEN']}&state=close"
    response = curl.get(url, headers)

    JSON::parse(response.body).select{ |obj| obj['closed_at'] != nil }.each do |pr|
      doc = <<-"EOS"
#{pr['closed_at']}：#{pr['title']}
      EOS

      puts doc
    end
  end
end
