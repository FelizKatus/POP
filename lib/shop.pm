package shop;

use Dancer2;
use Dancer2::Plugin::Database;
use Data::Dumper;

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

  $tokens->{'shop_css_url'}  = request->base . 'css/shop.css';
  $tokens->{'admin_css_url'} = request->base . 'css/admin.css';
  $tokens->{'login_url'}     = uri_for('/login');
  $tokens->{'logout_url'}    = uri_for('/logout');
  $tokens->{'contact_url'}   = uri_for('/contact');
};

hook database_error => sub {
  my $error = shift;

  die $error;
};

get '/' => sub {
  set layout => 'shop';

  template 'home.tt', {
    msg => get_flash(),
  };
};

get '/shop' => sub {
  set layout => 'shop';

  my $sql = 'select id, title, text from entries order by id desc';
  my $sth = database('shop')->prepare($sql);
  $sth->execute;

  template 'shop.tt', {
    msg           => get_flash(),
    add_entry_url => uri_for('/add'),
    entries       => $sth->fetchall_hashref('id'),
  };
};

get '/blog' => sub {
  set layout => 'shop';

  my $sql = 'select id, post_image, post_title, post_text, post_tags, post_home, post_subscriptions from posts order by id desc';
  my $sth = database('blog')->prepare($sql);
  $sth->execute;

  template 'blog.tt', {
    msg   => get_flash(),
    posts => $sth->fetchall_hashref('id'),
  };
};

get '/contact' => sub {
  set layout => 'shop';

  template 'contact.tt', {
    msg => get_flash(),
  };
};

post '/contact' => sub {
  set layout => 'shop';

  my $err;

  my $smail   = '/usr/sbin/sendmail';
  my $to      = 'contact@example.com';
  my $from    = body_parameters->get('email');
  my $subject = body_parameters->get('subject');
  my $message = body_parameters->get('message');
  my $check   = body_parameters->get('check');

  if(defined $check) {
    # process form input
    if(not defined $from or $from eq '') {
      $err = 'Invalid email';
    } elsif(not defined $message or $message eq '') {
      $err = 'Invalid message';
    } else {
      open(MAIL, "|$smail -t $to") or die("Error can't open $smail: $!\n");

      print MAIL "To: $to\n";
      print MAIL "From: $from\n";
      print MAIL "Subject: $subject\n";
      print MAIL "$message";

      close MAIL or die("Error can't close $smail: $!");

      set_flash('Email sent.');
    }
  } else {
    $err = 'You are a robot.';
  }

  template 'contact.tt', {
    err => $err,
    msg => get_flash(),
  };
};

any ['get', 'post'] => '/login' => sub {
  set layout => 'shop';

  my $err;
  my $check = body_parameters->get('check');

  if(request->method() eq "POST") {
    if(defined $check) {
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
    } else {
      $err = 'You are a robot.';
    }
  }

  # display login form
  template 'login.tt', {
    err => $err,
  };
};

get '/logout' => sub {
  set layout => 'shop';

  app->destroy_session;

  set_flash('You are logged out.');

  redirect '/';
};

any ['get', 'post'] => '/admin' => sub {
  if(not session('logged_in')) {
    send_error('Not logged in', 401);
  } else {
    my $err;

    set layout => 'admin';

    # display admin
    template 'admin.tt', {
      err => $err
    };
  }
};

get '/admin/posts' => sub {
  if(not session('logged_in')) {
    send_error('Not logged in', 401);
  } else {
    my $sql = 'select id, post_image, post_title, post_text, post_tags, post_home, post_subscriptions from posts order by id desc';
    my $sth = database('blog')->prepare($sql);
    $sth->execute;

    set layout => 'admin';

    template 'posts.tt', {
      msg          => get_flash(),
      posts        => $sth->fetchall_hashref('id'),
      add_post_url => uri_for('/admin/add_post')
    };
  }
};

post '/admin/add_post' => sub {
  if(not session('logged_in')) {
    send_error('Not logged in', 401);
  } else {
    my $sql = 'insert into posts (post_image, post_title, post_text, post_tags, post_home, post_subscriptions) values (?, ?, ?, ?, ?, ?)';
    my $sth = database('blog')->prepare($sql);

    $sth->execute(
      body_parameters->get('image'),
      body_parameters->get('title'),
      body_parameters->get('text'),
      body_parameters->get('tags'),
      body_parameters->get('home'),
      body_parameters->get('subscriptions'),
    );

    set_flash('New entry posted!');

    redirect '/admin/posts';
  }
};

true;
