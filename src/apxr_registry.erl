-module(apxr_registry).
-export([
	encode_names/1,
	decode_names/2,
	encode_versions/1,
	decode_versions/2,
	encode_project/1,
	decode_project/3,
	sign_protobuf/2,
	decode_signed/1,
	decode_and_verify_signed/2,
	sign/2,
	verify/3
]).
-include_lib("public_key/include/public_key.hrl").

-type private_key() :: public_key:rsa_private_key() | binary().
-type public_key() :: public_key:rsa_public_key() | binary().

%%====================================================================
%% API functions
%%====================================================================

%% @doc
%% Encode Names message.
encode_names(Names) ->
	apxr_pb_names:encode_msg(Names, 'names').

%% @doc
%% Decode message created with encode_names/1.
decode_names(Payload, Repository) ->
	case apxr_pb_names:decode_msg(Payload, 'names') of
		#{repository := Repository, projects := Projects} ->
			{ok, Projects};
		_ ->
			{error, unverified}
	end.

%% @doc
%% Encode Versions message.
encode_versions(Versions) ->
	apxr_pb_versions:encode_msg(Versions, 'versions').

%% @doc
%% Decode message created with encode_versions/1.
decode_versions(Payload, Repository) ->
	case apxr_pb_versions:decode_msg(Payload, 'versions') of
		#{repository := Repository, projects := Projects} ->
			{ok, Projects};
		_ ->
			{error, unverified}
	end.

%% @doc
%% Encode Project message.
encode_project(Project) ->
	apxr_pb_project:encode_msg(Project, 'project').

%% @doc
%% Decode message created with encode_project/1.
decode_project(Payload, Repository, Project) ->
	case apxr_pb_project:decode_msg(Payload, 'project') of
		#{repository := Repository, name := Project, releases := Releases} ->
    	{ok, Releases};
    _ ->
      {error, unverified}
   end.

%% @doc
%% Encode Signed message.
sign_protobuf(Payload, PrivateKey) ->
	Signature = sign(Payload, PrivateKey),
	apxr_pb_signed:encode_msg(#{payload => Payload, signature => Signature}, 'signed').

%% @doc
%% Decode message created with sign_protobuf/2 without verification.
decode_signed(Signed) ->
	apxr_pb_signed:decode_msg(Signed, 'signed').

%% @doc
%% Decode message created with sign_protobuf/2 and verify it against public key.
-spec decode_and_verify_signed(map(), public_key()) -> {ok, binary()} | {error, term()}.
decode_and_verify_signed(Signed, PublicKey) ->
	#{payload := Payload, signature := Signature} = decode_signed(Signed),
	case verify(Payload, Signature, PublicKey) of
		true -> {ok, Payload};
		false -> {error, unverified};
		{error, Reason} -> {error, Reason}
	end.

%% @doc
%% Signs binary with given private key.
-spec sign(binary(), private_key()) -> binary().
sign(Binary, PrivateKey) ->
	{ok, RSAPrivateKey} = key(PrivateKey),
	public_key:sign(Binary, sha512, RSAPrivateKey).

%% @doc
%% Verifies binary against signature and a public key.
-spec verify(binary(), binary(), public_key()) -> boolean() | {error, term()}.
verify(Binary, Signature, PublicKey) ->
	case key(PublicKey) of
		{ok, RSAPublicKey} -> public_key:verify(Binary, sha512, Signature, RSAPublicKey);
		{error, Reason} -> {error, Reason}
	end.

%%====================================================================
%% Internal functions
%%====================================================================

key(#'RSAPublicKey'{} = Key) ->
	{ok, Key};
key(#'RSAPrivateKey'{} = Key) ->
	{ok, Key};
key(Binary) when is_binary(Binary) ->
	case public_key:pem_decode(Binary) of
		[Entry | _] -> {ok, public_key:pem_entry_decode(Entry)};
		_ -> {error, bad_key}
	end.