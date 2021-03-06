#!/bin/bash -e
export USER=app

source /home/app/perl5/perlbrew/etc/bashrc

cpanm -n App::Sqitch \
 blib \
 Business::BR::CEP \
 Business::BR::CNPJ \
 Business::BR::CPF \
 Catalyst \
 Catalyst::Action::RenderView \
 Catalyst::Authentication::Store::DBIx::Class \
 Catalyst::Controller \
 Catalyst::Model \
 Catalyst::Model::DBIC::Schema \
 Catalyst::Plugin::Authentication \
 Catalyst::Plugin::Authorization::Roles \
 Catalyst::Plugin::ConfigLoader \
 Catalyst::Plugin::I18N \
 Catalyst::Plugin::Static::Simple \
 Catalyst::Runtime \
 Catalyst::Test \
 CatalystX::Eta::Controller::AutoBase \
 CatalystX::Eta::Controller::AutoListGET \
 CatalystX::Eta::Controller::AutoObject \
 CatalystX::Eta::Controller::AutoResultGET \
 CatalystX::Eta::Controller::AutoResultPUT \
 CatalystX::Eta::Controller::REST \
 CatalystX::Eta::Controller::Search \
 CatalystX::Eta::Controller::TypesValidation \
 CatalystX::Eta::Test::REST \
 common::sense \
 Config::General \
 Crypt::PRNG \
 Daemon::Generic \
 Data::Diver \
 Data::Dumper \
 Data::Fake \
 Data::Manager \
 Data::Printer \
 Data::Section::Simple \
 Data::Verifier::Field \
 Data::Verifier::Filters \
 Data::Verifier::Results \
 Data::Visitor \
 Data::Visitor::Callback \
 DateTime \
 DateTime::Format::Pg \
 DateTimeX::Easy \
 DBD::Pg \
 DBIx::Class::Core \
 DBIx::Class::InflateColumn::Serializer \
 DBIx::Class::PassphraseColumn \
 DBIx::Class::ResultSet \
 DBIx::Class::Schema \
 DBIx::Class::TimeStamp \
 Digest::SHA1 \
 Email::Sender::Simple \
 Email::Sender::Transport::SMTP::TLS \
 Email::Valid \
 ExtUtils::MakeMaker \
 File::MimeInfo \
 File::Spec \
 FindBin \
 Furl \
 HTTP::Request \
 HTTP::Request::Common \
 IO::Handle \
 IPC::Open3 \
 JSON::MaybeXS \
 JSON::XS \
 Log::Log4perl \
 MIME::Lite \
 Moose \
 Moose::Role \
 Moose::Util::TypeConstraints \
 MooseX::MarkAsMethods \
 MooseX::NonMoose \
 MooseX::Singleton \
 MooseX::Types \
 MooseX::Types::Common::String \
 MooseX::Types::DateTime::MoreCoercions \
 MooseX::Types::Moose \
 MooseX::Types::Structured \
 namespace::autoclean \
 Net::Flotum \
 Net::Server::SS::PreFork \
 Number::Phone::BR \
 Scalar::Util \
 Server::Starter \
 Starman \
 Template \
 Test::More \
 Time::HiRes \
 Try::Tiny::Retry