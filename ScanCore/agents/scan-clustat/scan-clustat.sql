-- NOTES 
--     - The public table must have a column called '<table_name>_id' which is
--       a 'bigserial'.
--     - The history schema must have a column called 'history_id' which is a
--       'bigserial' as well.
--     - There must be a column called 'X_host_id' that is a foreign key to 
--      'hosts -> host_id'.
--     

-- This is the database schema for the 'Clustat' scan agent.

CREATE TABLE clustat (
	clustat_id			bigserial			primary key,
	clustat_host_id			bigint,
	clustat_quorate			boolean,							-- Is this node quorate?
	clustat_cluster_name		text,								-- the cluster name reported by clustat.
	modified_date			timestamp with time zone	not null,
	
	FOREIGN KEY(clustat_host_id) REFERENCES hosts(host_id)
);
ALTER TABLE clustat OWNER TO #!variable!user!#;

CREATE TABLE history.clustat (
	history_id			bigserial,
	clustat_id			bigint,
	clustat_host_id			bigint,
	clustat_quorate			boolean,							-- Is this node quorate?
	clustat_cluster_name		text,								-- the cluster name reported by clustat.
	modified_date			timestamp with time zone	not null
);
ALTER TABLE history.clustat OWNER TO #!variable!user!#;

CREATE FUNCTION history_clustat() RETURNS trigger
AS $$
DECLARE
	history_clustat RECORD;
BEGIN
	SELECT INTO history_clustat * FROM clustat WHERE clustat_id=new.clustat_id;
	INSERT INTO history.clustat
		(clustat_id,
		 clustat_host_id,
		 clustat_quorate,
		 clustat_cluster_name,
		 modified_date)
	VALUES
		(history_clustat.clustat_id,
		 history_clustat.clustat_host_id,
		 history_clustat.clustat_quorate,
		 history_clustat.clustat_cluster_name,
		 history_clustat.modified_date);
	RETURN NULL;
END;
$$
LANGUAGE plpgsql;
ALTER FUNCTION history_clustat() OWNER TO #!variable!user!#;

CREATE TRIGGER trigger_clustat
	AFTER INSERT OR UPDATE ON clustat
	FOR EACH ROW EXECUTE PROCEDURE history_clustat();


	
-- This is where information on nodes, as reported by clustat, are stored.
CREATE TABLE clustat_node (
	clustat_node_id			bigserial,
	clustat_node_clustat_id		bigint				not null,
	clustat_node_cluster_id		bigint,								-- This is the node ID reported by clustat
	clustat_node_name		text,								-- Node name (from the 'Member Name' column)
	clustat_node_status		text,								-- Node status
	modified_date			timestamp with time zone	not null,
	
	FOREIGN KEY(clustat_node_clustat_id) REFERENCES clustat(clustat_id)
);
ALTER TABLE clustat_node OWNER TO #!variable!user!#;

CREATE TABLE history.clustat_node (
	history_id			bigserial,
	clustat_node_id			bigint,
	clustat_node_clustat_id		bigint,
	clustat_node_cluster_id		bigint,
	clustat_node_name		text,								-- Node name (from the 'Member Name' column)
	clustat_node_status		text,								-- Node status
	modified_date			timestamp with time zone	not null
);
ALTER TABLE history.clustat_node OWNER TO #!variable!user!#;

CREATE FUNCTION history_clustat_node() RETURNS trigger
AS $$
DECLARE
	history_clustat_node RECORD;
BEGIN
	SELECT INTO history_clustat_node * FROM clustat_node WHERE clustat_node_id=new.clustat_node_id;
	INSERT INTO history.clustat_node
		(clustat_node_id,
		 clustat_node_clustat_id,
		 clustat_node_cluster_id,
		 clustat_node_name,
		 clustat_node_status,
		 modified_date)
	VALUES
		(history_clustat_node.clustat_node_id,
		 history_clustat_node.clustat_node_clustat_id,
		 history_clustat_node.clustat_node_cluster_id,
		 history_clustat_node.clustat_node_name,
		 history_clustat_node.clustat_node_status,
		 history_clustat_node.modified_date);
	RETURN NULL;
END;
$$
LANGUAGE plpgsql;
ALTER FUNCTION history_clustat_node() OWNER TO #!variable!user!#;

CREATE TRIGGER trigger_clustat_node
	AFTER INSERT OR UPDATE ON clustat_node
	FOR EACH ROW EXECUTE PROCEDURE history_clustat_node();
	
	
-- This stores information about clustat services.
CREATE TABLE clustat_service (
	clustat_service_id		bigserial,
	clustat_service_clustat_id	bigint				not null,
	clustat_service_name		text,
	clustat_service_host		text,
	clustat_service_status		text,
	clustat_service_notes		text,
	clustat_service_is_vm		boolean				not null,
	modified_date			timestamp with time zone	not null,
	
	FOREIGN KEY(clustat_service_clustat_id) REFERENCES clustat(clustat_id)
);
ALTER TABLE clustat_service OWNER TO #!variable!user!#;

CREATE TABLE history.clustat_service (
	history_id			bigserial,
	clustat_service_id		bigint,
	clustat_service_clustat_id	bigint,
	clustat_service_name		text,
	clustat_service_host		text,
	clustat_service_status		text,
	clustat_service_notes		text,
	clustat_service_is_vm		boolean				not null,
	modified_date			timestamp with time zone	not null
);
ALTER TABLE history.clustat_service OWNER TO #!variable!user!#;

CREATE FUNCTION history_clustat_service() RETURNS trigger
AS $$
DECLARE
	history_clustat_service RECORD;
BEGIN
	SELECT INTO history_clustat_service * FROM clustat_service WHERE clustat_service_id=new.clustat_service_id;
	INSERT INTO history.clustat_service
		(clustat_service_id,
		 clustat_service_clustat_id,
		 clustat_service_name,
		 clustat_service_host,
		 clustat_service_status,
		 clustat_service_notes, 
		 clustat_service_is_vm,
		 modified_date)
	VALUES
		(history_clustat_service.clustat_service_id,
		 history_clustat_service.clustat_service_clustat_id,
		 history_clustat_service.clustat_service_name,
		 history_clustat_service.clustat_service_host,
		 history_clustat_service.clustat_service_status,
		 history_clustat_service.clustat_service_notes, 
		 history_clustat_service.clustat_service_is_vm,
		 history_clustat_service.modified_date);
	RETURN NULL;
END;
$$
LANGUAGE plpgsql;
ALTER FUNCTION history_clustat_service() OWNER TO #!variable!user!#;

CREATE TRIGGER trigger_clustat_service
	AFTER INSERT OR UPDATE ON clustat_service
	FOR EACH ROW EXECUTE PROCEDURE history_clustat_service();
