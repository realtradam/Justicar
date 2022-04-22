# note: `target` will always be relative to the current directory for
# postprocessor files

# this generates all of our preprocessed articles we stored
# note: you need to use the param `|_|` for paggio to allow us
#       to use local variables in the proc
Justicar::PreProcessor.articles.each do |key, val|
  target[key] = Paggio.html do |_|
    _.html do
      val
    end
  end
end

# this creates the articles page which contains links to
# all of our articles
target["index.html"] = Paggio.html do |_|
  _.html do
    _.h1 do
      'Here is a list of all the articles!'
    end
    Justicar::PreProcessor.articles.each do |key, val|
      _.p do
        _.a.articles(href: "#{key}") { key.delete_suffix('.html').upcase + "!" }
      end
    end
  end
end
