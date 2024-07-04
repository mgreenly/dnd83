@title="hello world"

def header
  <<~EOS.strip
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title>title</title>
      <link rel="stylesheet" href="assets/css/site.css">
      <script src="assets/js/site.js"></script>
    </head>
    <body>
  EOS
end

def footer
  <<~EOS.strip
    <script type="text/javascript">window.onload=main();</script>
    </body>
    </html>
  EOS
end

def title(string)
  %{<h1 class="title">#{string}</h1>}
end

def section(string)
  %{<h1 class="section">#{string}</h1>}
end
