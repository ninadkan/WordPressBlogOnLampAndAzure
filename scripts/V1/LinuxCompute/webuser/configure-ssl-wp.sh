#python py_file_replace_str.py ".htaccess" "RewriteBase /"  "RewriteBase / \nRewriteCond %{HTTPS} !=on \nRewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]"
#python py_file_replace_str.py ".htaccess" "RewriteRule . /index.php [L]" "RewriteRule . /index.php [L] \n# Rewrite HTTP to HTTPS \nRewriteCond %{HTTPS} !=on \nRewriteRule ^(.*) https://%{SERVER_NAME}/$1 [R,L]"
#python py_file_replace_str.py ".htaccess" "RewriteRule . /index.php [L]" "RewriteRule . /index.php [L] \n# Rewrite HTTP to HTTPS \nRewriteCond %{HTTPS} !=on \nRewriteRule ^(.*) https://blogs.ninadkanthi.co.uk/$1 [R,L]"
sudo python py_file_replace_str.py "wordpress.conf" "#Include conf-available/serve-cgi-bin.conf"  "#Include conf-available/serve-cgi-bin.conf \n\t\tRedirect / https://blogs.ninadkanthi.co.uk"

