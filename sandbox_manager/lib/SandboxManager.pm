package SandboxManager;
use Mojo::Base 'Mojolicious';
use Mojo::SQLite;
use Minion::Backend::SQLite;
use Mojolicious::Plugin::Minion;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer') if $config->{perldoc};
  $self->plugin(Minion => { SQLite => 'sqlite:/data/minion.db' });

  $self->helper( sqlite => sub { state $sql = Mojo::SQLite->new('sqlite:/data/sandboxes.db') } );

  say "SQLITE VERSION: " . $self->sqlite->db->query('select sqlite_version() as version')->hash->{version};

  $self->plugin('TemplateToolkit');
  $self->plugin(TemplateToolkit => {template => {INTERPOLATE => 1}});
  $self->renderer->default_handler('tt2');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('sandboxes#list');
  $r->get('/create')->to('sandboxes#create_form');
  $r->post('/create')->to('sandboxes#create_submit');
  $r->any('/provision/:name')->to('sandboxes#provision');
  $r->any('/provision_log/:name')->to('sandboxes#provision_log');
}

1;
