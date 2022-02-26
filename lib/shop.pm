package shop;

use Dancer2;
use Dancer2::Plugin::Database;

sub set_flash {
  my $message = shift;
  session flash => $message;
}

sub get_flash {
  my $msg = session('flash');
  session->delete('flash');
  return $msg;
}

hook before_template_render => sub {
  my $tokens = shift;
  $tokens->{'css_url'}    = request->base . 'css/style.css';
  $tokens->{'login_url'}  = uri_for('/login');
  $tokens->{'logout_url'} = uri_for('/logout');
};

hook database_error => sub {
  my $error = shift;
  die $error;
};

get '/' => sub {
  template 'home.tt', {
    msg => get_flash(),
  };
};

get '/shop' => sub {
  my $sql = 'select id, title, text from entries order by id desc';
  my $sth = database->prepare($sql);
  $sth->execute;
  template 'shop.tt', {
    msg           => get_flash(),
    add_entry_url => uri_for('/add'),
    entries       => $sth->fetchall_hashref('id'),
  };
};

get '/blog' => sub {
  template 'blog.tt', {
    msg => get_flash(),
  };
};

get '/contact' => sub {
  template 'contact.tt', {
    msg => get_flash(),
  };
};

post '/add' => sub {
  if(not session('logged_in')) {
    send_error("Not logged in", 401);
  }
  my $sql = 'insert into entries (title, text) values (?, ?)';
  my $sth = database->prepare($sql);
  $sth->execute(
    body_parameters->get('title'),
    body_parameters->get('text')
  );
  set_flash('New entry posted!');
  redirect '/';
};

any ['get', 'post'] => '/login' => sub {
  my $err;
  if(request->method() eq "POST") {
    # process form input
    if(body_parameters->get('username') ne setting('username')) {
      $err = 'Invalid username';
    } elsif(body_parameters->get('password') ne setting('password')) {
      $err = 'Invalid password';
    } else {
      session 'logged_in' => true;
      set_flash('You are logged in.');
      return redirect '/';
    }
  }
  # display login form
  template 'login.tt', {
    err => $err,
  };
};

get '/logout' => sub {
  app->destroy_session;
  set_flash('You are logged out.');
  redirect '/';
};

true;
