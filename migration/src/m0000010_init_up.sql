--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg120+2)
-- Dumped by pg_dump version 17.4 (Debian 17.4-1.pgdg120+2)

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: cvss3_a; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_a AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss3_ac; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_ac AS ENUM (
    'l',
    'h'
);


--
-- Name: cvss3_av; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_av AS ENUM (
    'n',
    'a',
    'l',
    'p'
);


--
-- Name: cvss3_c; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_c AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss3_i; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_i AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss3_pr; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_pr AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss3_s; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_s AS ENUM (
    'u',
    'c'
);


--
-- Name: cvss3_severity; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_severity AS ENUM (
    'none',
    'low',
    'medium',
    'high',
    'critical'
);


--
-- Name: cvss3_ui; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss3_ui AS ENUM (
    'n',
    'r'
);


--
-- Name: cvss4_ac; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_ac AS ENUM (
    'l',
    'h'
);


--
-- Name: cvss4_at; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_at AS ENUM (
    'n',
    'p'
);


--
-- Name: cvss4_av; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_av AS ENUM (
    'n',
    'a',
    'l',
    'p'
);


--
-- Name: cvss4_pr; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_pr AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss4_sa; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_sa AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss4_sc; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_sc AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss4_si; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_si AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss4_ui; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_ui AS ENUM (
    'n',
    'p',
    'a'
);


--
-- Name: cvss4_va; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_va AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss4_vc; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_vc AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss4_vi; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cvss4_vi AS ENUM (
    'n',
    'l',
    'h'
);


--
-- Name: cvss3_a_score(public.cvss3_a); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_a_score(a_p public.cvss3_a) RETURNS real
    LANGUAGE plpgsql
    AS $$
begin
    if a_p = 'n'::cvss3_a then
        return 0.0;
    elsif a_p = 'l'::cvss3_a then
        return 0.22;
    elsif a_p = 'h'::cvss3_a then
        return 0.56;
    end if;

    return 0.85;

end;
$$;


--
-- Name: cvss3_ac_score(public.cvss3_ac); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_ac_score(ac_p public.cvss3_ac) RETURNS real
    LANGUAGE plpgsql
    AS $$
begin
    if ac_p = 'h'::cvss3_ac then
        return 0.44;
    elsif ac_p = 'l'::cvss3_ac then
        return 0.77;
    end if;

    return 0.0;

end;
$$;


--
-- Name: cvss3_av_score(public.cvss3_av); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_av_score(av_p public.cvss3_av) RETURNS real
    LANGUAGE plpgsql
    AS $$
begin
    if av_p = 'p'::cvss3_av then
        return 0.20;
    elsif av_p = 'l'::cvss3_av then
        return 0.55;
    elsif av_p = 'a'::cvss3_av then
        return 0.62;
    elsif av_p = 'n'::cvss3_av then
        return 0.85;
    end if;

    return 0.0;

end;
$$;


--
-- Name: cvss3_c_score(public.cvss3_c); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_c_score(c_p public.cvss3_c) RETURNS real
    LANGUAGE plpgsql
    AS $$
begin
    if c_p = 'n'::cvss3_c then
        return 0.0;
    elsif c_p = 'l'::cvss3_c then
        return 0.22;
    elsif c_p = 'h'::cvss3_c then
        return 0.56;
    end if;

    return 0.85;

end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cvss3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cvss3 (
    minor_version integer NOT NULL,
    av public.cvss3_av NOT NULL,
    ac public.cvss3_ac NOT NULL,
    pr public.cvss3_pr NOT NULL,
    ui public.cvss3_ui NOT NULL,
    s public.cvss3_s NOT NULL,
    c public.cvss3_c NOT NULL,
    i public.cvss3_i NOT NULL,
    a public.cvss3_a NOT NULL,
    advisory_id uuid NOT NULL,
    score double precision NOT NULL,
    severity public.cvss3_severity NOT NULL,
    vulnerability_id character varying NOT NULL
);


--
-- Name: cvss3_exploitability(public.cvss3); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_exploitability(cvss3_p public.cvss3) RETURNS real
    LANGUAGE plpgsql
    AS $$
declare
    av_score decimal;
    ac_score decimal;
    ui_score decimal;
    pr_score decimal;
    scope_changed bool;
begin
    scope_changed = cvss3_scope_changed(cvss3_p.s);

    av_score := cvss3_av_score(cvss3_p.av);
    ac_score := cvss3_ac_score(cvss3_p.ac);
    ui_score := cvss3_ui_score(cvss3_p.ui);
    pr_score := cvss3_pr_scoped_score(cvss3_p.pr, scope_changed);


    return (8.22 * av_score * ac_score * pr_score * ui_score);
end;
$$;


--
-- Name: cvss3_i_score(public.cvss3_i); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_i_score(i_p public.cvss3_i) RETURNS real
    LANGUAGE plpgsql
    AS $$
begin
    if i_p = 'n'::cvss3_i then
        return 0.0;
    elsif i_p = 'l'::cvss3_i then
        return 0.22;
    elsif i_p = 'h'::cvss3_i then
        return 0.56;
    end if;

    return 0.85;

end;
$$;


--
-- Name: cvss3_impact(public.cvss3); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_impact(cvss3_p public.cvss3) RETURNS real
    LANGUAGE plpgsql
    AS $$
declare
    c_score decimal;
    i_score decimal;
    a_score decimal;
begin
    c_score := cvss3_c_score(cvss3_p.c);
    i_score := cvss3_i_score(cvss3_p.i);
    a_score := cvss3_a_score(cvss3_p.a);

    return (1.0 - abs((1.0 - c_score) * (1.0 - i_score) * (1.0 - a_score)));
end;
$$;


--
-- Name: cvss3_pr_scoped_score(public.cvss3_pr, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_pr_scoped_score(pr_p public.cvss3_pr, scope_changed_p boolean) RETURNS real
    LANGUAGE plpgsql
    AS $$
begin
    if pr_p = 'h'::cvss3_pr then
        if scope_changed_p then
            return 0.50;
        else
            return 0.27;
        end if;
    elsif pr_p = 'l'::cvss3_pr then
        if scope_changed_p then
            return 0.68;
        else
            return 0.62;
        end if;
    end if;

    return 0.85;

end;
$$;


--
-- Name: cvss3_scope_changed(public.cvss3_s); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_scope_changed(s_p public.cvss3_s) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
    return s_p = 'c'::cvss3_s;

end;
$$;


--
-- Name: cvss3_score(public.cvss3); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_score(cvss3_p public.cvss3) RETURNS real
    LANGUAGE plpgsql
    AS $$
declare
    exploitability decimal;
    iss decimal;
    iss_scoped decimal;
    score decimal;
begin
    if cvss3_p is null then
        return null;
    end if;

    exploitability := cvss3_exploitability(cvss3_p);
    iss = cvss3_impact( cvss3_p );

    if not(cvss3_scope_changed( cvss3_p.s)) then
        iss_scoped := 6.42 * iss;
    else
        iss_scoped := (7.52 * (iss - 0.029)) - pow(3.25 * (iss - 0.02), 15.0);
    end if;

    if iss_scoped <= 0.0 then
        score := 0.0;
    elsif not(cvss3_scope_changed( cvss3_p.s)) then
        score := least(iss_scoped + exploitability, 10.0);
    else
        score := least(1.08 * (iss_scoped + exploitability), 10.0);
    end if;

    return score;
end
$$;


--
-- Name: cvss3_severity(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_severity(score_p double precision) RETURNS public.cvss3_severity
    LANGUAGE plpgsql
    AS $$
declare
    exploitability decimal;
    iss decimal;
    iss_scoped decimal;
    score decimal;
begin
    if score_p is null then
        return null;
    end if;

    if score_p <= 3.9 then
        return 'low'::"cvss3_severity";
    end if;

    if score_p <= 6.9 then
        return 'medium'::"cvss3_severity";
    end if;

    if score_p <= 8.9 then
        return 'high'::"cvss3_severity";
    end if;

    return 'critical'::"cvss3_severity";
end
$$;


--
-- Name: cvss3_ui_score(public.cvss3_ui); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cvss3_ui_score(ui_p public.cvss3_ui) RETURNS real
    LANGUAGE plpgsql
    AS $$
begin
    if ui_p = 'r'::cvss3_ui then
        return 0.62;
    end if;

    return 0.85;

end;
$$;


--
-- Name: encode_uri_component(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.encode_uri_component(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT string_agg(
        CASE
            WHEN bytes > 1 or c !~ '[0-9a-zA-Z_.!~*''()-]+' THEN
                regexp_replace(encode(convert_to(c, 'utf-8')::bytea, 'hex'), '(..)', E'%\\1', 'g')
            ELSE
                c
            END,
        ''
    )
    FROM (
        SELECT c, octet_length(c) bytes
        FROM regexp_split_to_table($1, '') c
    ) q;
$_$;


--
-- Name: version_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_range (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    version_scheme_id character varying NOT NULL,
    low_version character varying,
    low_inclusive boolean,
    high_version character varying,
    high_inclusive boolean
);


--
-- Name: generic_version_matches(text, public.version_range); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generic_version_matches(version_p text, range_p public.version_range) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    if range_p.low_version is not null then
        if range_p.low_inclusive then
            if version_p = range_p.low_version then
                return true;
            end if;
        end if;
    end if;

    if range_p.high_version is not null then
        if range_p.high_inclusive then
            if version_p = range_p.high_version  then
                return true;
            end if;
        end if;
    end if;

    return false;

end
$$;


--
-- Name: get_purl(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_purl(qualified_purl_id uuid) RETURNS text
    LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
    AS $$
DECLARE
result TEXT;
BEGIN
SELECT
    COALESCE(
            'pkg:' || bp.type ||
            '/' || COALESCE(bp.namespace, '') || '/' ||
            bp.name ||
            '@' || vp.version ||
            CASE
                WHEN qp.qualifiers IS NOT NULL AND qp.qualifiers <> '{}'::jsonb THEN
                    '?' || (
                        SELECT string_agg(key || '=' || encode_uri_component(value), '&')
                        FROM jsonb_each_text(qp.qualifiers)
                    )
                ELSE
                    ''
                END,
            qualified_purl_id::text
    )
INTO result
FROM
    qualified_purl qp
        LEFT JOIN versioned_purl vp ON vp.id = qp.versioned_purl_id
        LEFT JOIN base_purl bp ON bp.id = vp.base_purl_id
WHERE
    qp.id = qualified_purl_id;

RETURN result;
END;
$$;


--
-- Name: gitver_version_matches(text, public.version_range); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gitver_version_matches(version_p text, range_p public.version_range) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
    if range_p.low_version is not null then
        if range_p.low_inclusive then
            if version_p = range_p.low_version then
                return true;
            end if;
        end if;
    end if;

    if range_p.high_version is not null then
        if range_p.high_inclusive then
            if version_p = range_p.high_version  then
                return true;
            end if;
        end if;
    end if;

    return false;

end
$$;


--
-- Name: is_numeric(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_numeric(str text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
begin
    return str ~ e'^[0-9]+$';
end

$_$;


--
-- Name: maven_version_matches(text, public.version_range); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.maven_version_matches(version_p text, range_p public.version_range) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    low_end integer;
    high_end integer;
begin
    if range_p.low_version is not null then
        low_end := mavenver_cmp(version_p, range_p.low_version);
    end if;

    if low_end is not null then
        if range_p.low_inclusive then
            if low_end < 0 then
                return false;
            end if;
        else
            if low_end <= 0 then
                return false;
            end if;
        end if;

    end if;


    if range_p.high_version is not null then
        high_end := mavenver_cmp(version_p, range_p.high_version);
    end if;

    if high_end is not null then
        if range_p.high_inclusive then
            if high_end > 0 then
                return false;
            end if;
        else
            if high_end >= 0 then
                return false;
            end if;
        end if;
    end if;

    if low_end is null and high_end is null then
        return false;
    end if;

    return true;

end
$$;


--
-- Name: mavenver_cmp(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mavenver_cmp(left_p text, right_p text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
declare
left_parts text[];
    right_parts text[];

    left_major bigint;
    left_minor bigint;
    left_revision bigint;
    left_qualifier_or_build text;
    left_qualifier text;
    left_build bigint;

    left_cardinality integer;

    right_major bigint;
    right_minor bigint;
    right_revision bigint;
    right_qualifier_or_build text;
    right_qualifier text;
    right_build bigint;

    right_cardinality integer;

    left_numeric bool;
    right_numeric bool;

    cur integer;

begin
    left_qualifier_or_build = substring(left_p, E'-\\S+$');

    left_parts = regexp_split_to_array(substring(left_p, E'^[^-]+'), E'\\.');
    left_major = left_parts[1]::bigint;
    left_minor = coalesce(left_parts[2]::bigint, 0);
    left_revision = coalesce(left_parts[3]::bigint, 0);

    right_qualifier_or_build = substring(right_p, E'-\\S+$');

    right_parts = regexp_split_to_array(substring(right_p, E'^[^-]+'), E'\\.');
    right_major = right_parts[1]::bigint;
    right_minor = coalesce(right_parts[2]::bigint, 0);
    right_revision = coalesce(right_parts[3]::bigint, 0);

    if left_major > right_major then
        return +1;
    elsif left_major < right_major then
        return -1;
end if;

    if left_minor > right_minor then
        return +1;
    elsif left_minor < right_minor then
        return -1;
end if;

    if left_revision > right_revision then
        return +1;
    elsif left_revision < right_revision then
        return -1;
end if;

    left_cardinality := greatest(cardinality(left_parts), 3);
    right_cardinality := greatest(cardinality(right_parts), 3);

    if left_cardinality > right_cardinality then
        return +1;
    elsif left_cardinality < right_cardinality then
        return -1;
end if;

    if left_qualifier_or_build is null and right_qualifier_or_build is null then
        return 0;
end if;

    if left_qualifier_or_build is null then
        return +1;
end if;

    if right_qualifier_or_build is null then
        return -1;
end if;

    left_numeric := is_numeric(left_qualifier_or_build);
    right_numeric := is_numeric(left_qualifier_or_build);

    if left_numeric and right_numeric then
        left_build = left_qualifier_or_build::bigint;
        right_build = right_qualifier_or_build::bigint;
        if left_build < right_build then
            return -1;
        elseif left_build > right_build then
            return +1;
else
            return 0;
end if;
end if;

    left_qualifier = lower(left_qualifier_or_build);
    right_qualifier = lower(right_qualifier_or_build);

    if left_qualifier < right_qualifier then
        return -1;
    elsif left_qualifier > right_qualifier then
        return +1;
end if;

return 0;
exception
    when others then
        return null;
end
$_$;


--
-- Name: package_transitive(uuid, text, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.package_transitive(sbom_id_param uuid, start_node_id text, relationships_param integer[]) RETURNS TABLE(left_node_id text, right_node_id text)
    LANGUAGE plpgsql
    AS $$
    begin

        return query
        with recursive transitive as (
            select
                package_relates_to_package.left_node_id,
                package_relates_to_package.right_node_id,
                package_relates_to_package.relationship,
                package_relates_to_package.sbom_id
            from
                package_relates_to_package
            where
                package_relates_to_package.right_node_id = start_node_id
                and package_relates_to_package.relationship = any(relationships_param)
                and package_relates_to_package.sbom_id = sbom_id_param
            union
            select
                prp.left_node_id,
                prp.right_node_id,
                prp.relationship,
                prp.sbom_id
            from
                package_relates_to_package prp
                    inner join transitive transitive1
                        on
                            prp.right_node_id = transitive1.left_node_id
                            and prp.relationship = any(relationships_param)
                            and prp.sbom_id = transitive1.sbom_id
        )
        select
            cast(transitive.left_node_id as text),
            cast(transitive.right_node_id as text)
        from
            transitive;
end;
$$;


--
-- Name: python_version_matches(text, public.version_range); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.python_version_matches(version_p text, range_p public.version_range) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    low_end integer;
    high_end integer;
begin
    if range_p.low_version is not null then
        low_end := pythonver_cmp(version_p, range_p.low_version);
    end if;

    if low_end is not null then
        if range_p.low_inclusive then
            if low_end < 0 then
                return false;
            end if;
        else
            if low_end <= 0 then
                return false;
            end if;
        end if;

    end if;


    if range_p.high_version is not null then
        high_end := pythonver_cmp(version_p, range_p.high_version);
    end if;

    if high_end is not null then
        if range_p.high_inclusive then
            if high_end > 0 then
                return false;
            end if;
        else
            if high_end >= 0 then
                return false;
            end if;
        end if;
    end if;

    if low_end is null and high_end is null then
        return false;
    end if;

    return true;

end
$$;


--
-- Name: pythonver_cmp(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pythonver_cmp(left_p text, right_p text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
left_parts text[];
    right_parts text[];

    left_major BIGINT;
    left_minor BIGINT;
    left_patch BIGINT;

    right_major BIGINT;
    right_minor BIGINT;
    right_patch BIGINT;

    -- Pre-release, Post-release, Dev-release
    left_pre TEXT := NULL;
    right_pre TEXT := NULL;

    left_pre_num BIGINT := NULL;
    right_pre_num BIGINT := NULL;

    left_post BIGINT := NULL;
    right_post BIGINT := NULL;

    left_dev BIGINT := NULL;
    right_dev BIGINT := NULL;
BEGIN

    left_parts = regexp_split_to_array(substring(left_p, E'^[^[:alpha:]]+'), E'\\.');
    left_major = left_parts[1]::bigint;
    left_minor = coalesce(left_parts[2]::bigint, 0);
    left_patch = coalesce(left_parts[3]::bigint, 0);

    right_parts = regexp_split_to_array(substring(right_p, E'^[^[:alpha:]]+'), E'\\.');
    right_major = right_parts[1]::bigint;
    right_minor = coalesce(right_parts[2]::bigint, 0);
    right_patch = coalesce(right_parts[3]::bigint, 0);

IF left_major > right_major THEN RETURN +1;
    ELSIF left_major < right_major THEN RETURN -1;
END IF;

    IF left_minor > right_minor THEN RETURN +1;
    ELSIF left_minor < right_minor THEN RETURN -1;
END IF;

    IF left_patch > right_patch THEN RETURN +1;
    ELSIF left_patch < right_patch THEN RETURN -1;
END IF;

    -- Extract pre-release versions (allow `a1`, `b2`, `rc3` without hyphen)
    left_pre := (regexp_match(left_p, '(a|b|rc)(\d*)'))[1];
    left_pre_num := NULLIF((regexp_match(left_p, '(a|b|rc)(\d*)'))[2], '')::BIGINT;

    right_pre := (regexp_match(right_p, '(a|b|rc)(\d*)'))[1];
    right_pre_num := NULLIF((regexp_match(right_p, '(a|b|rc)(\d*)'))[2], '')::BIGINT;

    IF left_pre IS NOT NULL AND right_pre IS NULL THEN RETURN -1; END IF;
    IF right_pre IS NOT NULL AND left_pre IS NULL THEN RETURN +1; END IF;

    -- Compare pre-release versions (alpha < beta < rc)
    IF left_pre IS NOT NULL AND right_pre IS NOT NULL THEN
        IF left_pre < right_pre THEN RETURN -1;
        ELSIF left_pre > right_pre THEN RETURN +1;
        ELSIF left_pre_num < right_pre_num THEN RETURN -1;
        ELSIF left_pre_num > right_pre_num THEN RETURN +1;
END IF;
END IF;

    -- Extract post-release versions (postN)
    left_post := NULLIF((regexp_match(left_p, 'post(\d+)'))[1], '')::BIGINT;
    right_post := NULLIF((regexp_match(right_p, 'post(\d+)'))[1], '')::BIGINT;

    IF left_post IS NOT NULL AND right_post IS NULL THEN RETURN +1; END IF;
    IF right_post IS NOT NULL AND left_post IS NULL THEN RETURN -1; END IF;
    IF left_post IS NOT NULL AND right_post IS NOT NULL THEN
        IF left_post > right_post THEN RETURN +1;
        ELSIF left_post < right_post THEN RETURN -1;
END IF;
END IF;

    -- Extract dev-release versions (devN)
    left_dev := NULLIF((regexp_match(left_p, 'dev(\d+)'))[1], '')::BIGINT;
    right_dev := NULLIF((regexp_match(right_p, 'dev(\d+)'))[1], '')::BIGINT;

    IF left_dev IS NOT NULL AND right_dev IS NULL THEN RETURN -1; END IF;
    IF right_dev IS NOT NULL AND left_dev IS NULL THEN RETURN +1; END IF;
    IF left_dev IS NOT NULL AND right_dev IS NOT NULL THEN
        IF left_dev > right_dev THEN RETURN +1;
        ELSIF left_dev < right_dev THEN RETURN -1;
END IF;
END IF;

    -- If everything is equal, return 0
RETURN 0;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END
$$;


--
-- Name: qualified_package_transitive(uuid, uuid, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.qualified_package_transitive(sbom_id_param uuid, start_qualified_purl_id uuid, relationships_param integer[]) RETURNS TABLE(left_package_id uuid, right_package_id uuid)
    LANGUAGE plpgsql
    AS $$
begin

    return query
    select
        left_id.qualified_purl_id,
        right_id.qualified_purl_id
    from (
        select
            node_id
        from
            sbom_package_purl_ref AS source
        where
            source.qualified_purl_id = start_qualified_purl_id
            and
            source.sbom_id = sbom_id_param
    ) AS t

     cross join lateral package_transitive(sbom_id_param, t.node_id, relationships_param) as result
     join sbom_package_purl_ref as left_id
            on
                left_id.node_id = result.left_node_id
                and left_id.sbom_id = sbom_id_param
     join sbom_package_purl_ref as right_id
            on
                right_id.node_id = result.right_node_id
                and right_id.sbom_id = sbom_id_param
    ;

end
$$;


--
-- Name: rpmver_cmp(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rpmver_cmp(a text, b text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    a_segments text[];
    b_segments text[];
    a_len integer;
    b_len integer;
    a_seg text;
    b_seg text;
begin
    if a = b then return 0; end if;
    a_segments := array(select (regexp_matches(a, '(\d+|[a-zA-Z]+|[~^])', 'g'))[1]);
    b_segments := array(select (regexp_matches(b, '(\d+|[a-zA-Z]+|[~^])', 'g'))[1]);
    a_len := array_length(a_segments, 1);
    b_len := array_length(b_segments, 1);
    for i in 1..coalesce(least(a_len, b_len) + 1, 0) loop
        a_seg = a_segments[i];
        b_seg = b_segments[i];
        if a_seg ~ '^\d' then
            if b_seg ~ '^\d' then
                a_seg := ltrim(a_seg, '0');
                b_seg := ltrim(b_seg, '0');
                case
                    when length(a_seg) > length(b_seg) then return 1;
                    when length(a_seg) < length(b_seg) then return -1;
                    else null; -- equality -> fallthrough to string comparison
                end case;
            else
                return 1;
            end if;
        elsif b_seg ~ '^\d' then
            return -1;
        elsif a_seg = '~' then
            if b_seg != '~' then
                return -1;
            end if;
        elsif b_seg = '~' then
            return 1;
        elsif a_seg = '^' then
            if b_seg != '^' then
                return 1;
            end if;
        elsif b_seg = '^' then
            return -1;
        end if;
        if a_seg != b_seg then
            if a_seg < b_seg then
                return -1;
            else
                return 1;
            end if;
        end if;
    end loop;
    if b_segments[a_len + 1] = '~' then return 1; end if;
    if a_segments[b_len + 1] = '~' then return -1; end if;
    if b_segments[a_len + 1] = '^' then return -1; end if;
    if a_segments[b_len + 1] = '^' then return 1; end if;
    if a_len > b_len then return 1; end if;
    if a_len < b_len then return -1; end if;
    return 0;
end $$;


--
-- Name: rpmver_version_matches(text, public.version_range); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rpmver_version_matches(version_p text, range_p public.version_range) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    low_end integer;
    high_end integer;
begin
    if range_p.low_version is not null then
        low_end := rpmver_cmp(version_p, range_p.low_version);
    end if;

    if low_end is not null then
        if range_p.low_inclusive then
            if low_end < 0 then
                return false;
            end if;
        else
            if low_end <= 0 then
                return false;
            end if;
        end if;

    end if;


    if range_p.high_version is not null then
        high_end := rpmver_cmp(version_p, range_p.high_version);
    end if;

    if high_end is not null then
        if range_p.high_inclusive then
            if high_end > 0 then
                return false;
            end if;
        else
            if high_end >= 0 then
                return false;
            end if;
        end if;
    end if;

    if low_end is null and high_end is null then
        return false;
    end if;

    return true;

end
$$;


--
-- Name: semver_cmp(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.semver_cmp(left_p text, right_p text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
left_parts text[];
    right_parts text[];

    left_major bigint;
    left_minor bigint;
    left_patch bigint;
    left_pre text;
    left_build text;

    left_cardinality integer;

    right_major bigint;
    right_minor bigint;
    right_patch bigint;
    right_pre text;
    right_build text;

    right_cardinality integer;

    left_numeric bool;
    right_numeric bool;

    cur integer;

begin
    left_parts = regexp_split_to_array(left_p, E'\\+');
    left_build = left_parts[2];

    left_parts = regexp_split_to_array(left_parts[1], E'-');
    left_pre = left_parts[2];

    left_parts = regexp_split_to_array(left_parts[1], E'\\.');
    left_major = left_parts[1]::decimal;
    left_minor = left_parts[2]::decimal;
    left_patch = left_parts[3]::decimal;

    right_parts = regexp_split_to_array(right_p, E'\\+');
    right_build = right_parts[2];

    right_parts = regexp_split_to_array(right_parts[1], E'-');
    right_pre = right_parts[2];

    right_parts = regexp_split_to_array(right_parts[1], E'\\.');
    right_major = right_parts[1]::decimal;
    right_minor = right_parts[2]::decimal;
    right_patch = right_parts[3]::decimal;

    if left_major > right_major then
        return +1;
    elsif left_major < right_major then
        return -1;
end if;

    if left_minor > right_minor then
        return +1;
    elsif left_minor < right_minor then
        return -1;
end if;

    if left_patch > right_patch then
        return +1;
    elsif left_patch < right_patch then
        return -1;
end if;

    left_cardinality := greatest(cardinality(left_parts), 3);
    right_cardinality := greatest(cardinality(right_parts), 3);

    if left_cardinality > right_cardinality then
        return +1;
    elsif left_cardinality < right_cardinality then
        return -1;
end if;

    if left_pre is null and right_pre is not null then
        return +1;
    elsif left_pre is not null and right_pre is null then
        return -1;
    elsif left_pre is not null and right_pre is not null then
        left_parts = regexp_split_to_array(left_pre, E'\\.');
        right_parts = regexp_split_to_array(right_pre, E'\\.');
        -- do the hard work

        cur := 0;
        loop
cur := cur + 1;

            left_pre := left_parts[cur];
            right_pre := right_parts[cur];

            if left_pre is null and right_pre is null then
                return 0;
end if;

            if left_pre is null and right_pre is not null then
                return -1;
            elsif left_pre is not null and right_pre is null then
                return +1;
end if;

            left_numeric := is_numeric(left_pre);
            right_numeric := is_numeric(right_pre);

            if left_numeric and right_numeric then
                if left_pre::bigint < right_pre::bigint then
                    return -1;
                elsif left_pre::bigint > right_pre::bigint then
                    return +1;
end if;
else
                if left_pre < right_pre then
                    return -1;
                elsif left_pre > right_pre then
                    return +1;
end if;
end if;

            if cur > 10 then
                exit;
end if;
end loop;
else
        return 0;
end if;

return null;
exception
    when others then
        return null;
end
$$;


--
-- Name: semver_eq(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.semver_eq(left_p text, right_p text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    cmp integer;
begin
    cmp := semver_cmp(left_p, right_p);
    return cmp = 0;
end
$$;


--
-- Name: semver_gt(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.semver_gt(left_p text, right_p text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    cmp integer;
begin
    cmp := semver_cmp(left_p, right_p);
    return cmp > 0;
end
$$;


--
-- Name: semver_gte(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.semver_gte(left_p text, right_p text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    cmp integer;
begin
    cmp := semver_cmp(left_p, right_p);
    return cmp >= 0;
end
$$;


--
-- Name: semver_lt(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.semver_lt(left_p text, right_p text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    cmp integer;
begin
    cmp := semver_cmp(left_p, right_p);
    return cmp < 0;
end
$$;


--
-- Name: semver_lte(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.semver_lte(left_p text, right_p text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    cmp integer;
begin
    cmp := semver_cmp(left_p, right_p);
    return cmp <= 0;
end
$$;


--
-- Name: semver_version_matches(text, public.version_range); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.semver_version_matches(version_p text, range_p public.version_range) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
    low_end integer;
    high_end integer;
begin
    if range_p.low_version is not null then
        low_end := semver_cmp(version_p, range_p.low_version);
    end if;

    if low_end is not null then
        if range_p.low_inclusive then
            if low_end < 0 then
                return false;
            end if;
        else
            if low_end <= 0 then
                return false;
            end if;
        end if;

    end if;


    if range_p.high_version is not null then
        high_end := semver_cmp(version_p, range_p.high_version);
    end if;

    if high_end is not null then
        if range_p.high_inclusive then
            if high_end > 0 then
                return false;
            end if;
        else
            if high_end >= 0 then
                return false;
            end if;
        end if;
    end if;

    if low_end is null and high_end is null then
        return false;
    end if;

    return true;

end
$$;


--
-- Name: update_deprecated_advisory(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_deprecated_advisory(identifier_input text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH MostRecent AS (SELECT DISTINCT ON (identifier) id
                        FROM advisory
                        WHERE identifier = COALESCE(identifier_input, identifier)
                        ORDER BY identifier, modified DESC)
    UPDATE advisory
    SET deprecated = CASE
                         WHEN id IN (SELECT id FROM MostRecent) THEN FALSE
                         ELSE TRUE
        END
    WHERE identifier = COALESCE(identifier_input, identifier);
END;
$$;


--
-- Name: version_matches(text, public.version_range); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.version_matches(version_p text, range_p public.version_range) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
begin
    -- for an authoritative list of support schemes, see the enum
    -- `trustify_entity::version_scheme::VersionScheme`
    return case
        when range_p.version_scheme_id = 'git'
            -- Git is git, and hard.
            then gitver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'semver'
            -- Semver is semver
            then semver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'gem'
            -- RubyGems claims to be semver
            then semver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'npm'
            -- NPM claims to be semver
            then semver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'golang'
            -- Golang claims to be semver
            then semver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'nuget'
            -- NuGet claims to be semver
            then semver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'generic'
            -- Just check if it is equal
            then generic_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'rpm'
            -- Look at me! I'm an RPM! I'm special!
            then rpmver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'maven'
            -- Look at me! I'm a Maven! I'm kinda special!
            then maven_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'python'
            -- Python versioning
            then python_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'packagist'
            -- Packagist PHP strongly encourages semver
            then semver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'hex'
            -- Erlang Hex claims to be semver
            then semver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'swift'
            -- Swift Package Manager claims to be semver
            then semver_version_matches(version_p, range_p)
        when range_p.version_scheme_id = 'pub'
            -- Pub Dart Flutter claims to be semver
            then semver_version_matches(version_p, range_p)
        else
            false
    end;
end
$$;


--
-- Name: advisory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.advisory (
    issuer_id uuid,
    published timestamp with time zone,
    modified timestamp with time zone,
    withdrawn timestamp with time zone,
    identifier character varying NOT NULL,
    title character varying,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    labels jsonb NOT NULL,
    source_document_id uuid,
    version character varying,
    deprecated boolean DEFAULT false,
    document_id character varying NOT NULL
);


--
-- Name: advisory_vulnerability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.advisory_vulnerability (
    title character varying,
    summary character varying,
    description character varying,
    discovery_date timestamp with time zone,
    release_date timestamp with time zone,
    advisory_id uuid NOT NULL,
    vulnerability_id character varying NOT NULL,
    cwes text[],
    reserved_date timestamp with time zone
);


--
-- Name: base_purl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_purl (
    id uuid NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    type character varying NOT NULL,
    namespace character varying,
    name character varying NOT NULL
);


--
-- Name: cpe; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cpe (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    part character varying,
    vendor character varying,
    product character varying,
    version character varying,
    update character varying,
    edition character varying,
    language character varying,
    sw_edition character varying,
    target_sw character varying,
    target_hw character varying,
    other character varying
);


--
-- Name: cpe_license_assertion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cpe_license_assertion (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    license_id uuid NOT NULL,
    sbom_id uuid NOT NULL,
    cpe_id uuid NOT NULL
);


--
-- Name: cvss4; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cvss4 (
    minor_version integer NOT NULL,
    av public.cvss4_av NOT NULL,
    ac public.cvss4_ac NOT NULL,
    at public.cvss4_at NOT NULL,
    pr public.cvss4_pr NOT NULL,
    ui public.cvss4_ui NOT NULL,
    vc public.cvss4_vc NOT NULL,
    vi public.cvss4_vi NOT NULL,
    va public.cvss4_va NOT NULL,
    sc public.cvss4_sc NOT NULL,
    si public.cvss4_si NOT NULL,
    sa public.cvss4_sa NOT NULL,
    advisory_id uuid NOT NULL,
    vulnerability_id character varying NOT NULL
);


--
-- Name: importer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.importer (
    name character varying NOT NULL,
    revision uuid NOT NULL,
    state integer NOT NULL,
    last_change timestamp with time zone,
    last_error character varying,
    last_success timestamp with time zone,
    last_run timestamp with time zone,
    continuation jsonb,
    configuration jsonb,
    progress_current integer,
    progress_total integer,
    progress_message character varying
);


--
-- Name: importer_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.importer_report (
    id uuid NOT NULL,
    importer character varying NOT NULL,
    creation timestamp with time zone NOT NULL,
    error character varying,
    report jsonb NOT NULL
);


--
-- Name: license; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.license (
    id uuid NOT NULL,
    text character varying NOT NULL,
    spdx_licenses text[],
    spdx_license_exceptions text[]
);


--
-- Name: organization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    cpe_key character varying,
    website character varying
);


--
-- Name: package_relates_to_package; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_relates_to_package (
    left_node_id character varying NOT NULL,
    relationship integer NOT NULL,
    right_node_id character varying NOT NULL,
    sbom_id uuid NOT NULL
);


--
-- Name: product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    vendor_id uuid,
    cpe_key character varying
);


--
-- Name: product_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_status (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    advisory_id uuid NOT NULL,
    vulnerability_id character varying NOT NULL,
    status_id uuid NOT NULL,
    product_version_range_id uuid NOT NULL,
    context_cpe_id uuid,
    package character varying
);


--
-- Name: product_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_version (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    product_id uuid NOT NULL,
    sbom_id uuid,
    version character varying NOT NULL
);


--
-- Name: product_version_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_version_range (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    version_range_id uuid NOT NULL,
    cpe_key character varying
);


--
-- Name: purl_license_assertion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purl_license_assertion (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    license_id uuid NOT NULL,
    sbom_id uuid NOT NULL,
    versioned_purl_id uuid NOT NULL
);


--
-- Name: purl_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purl_status (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    advisory_id uuid NOT NULL,
    status_id uuid NOT NULL,
    base_purl_id uuid NOT NULL,
    version_range_id uuid NOT NULL,
    vulnerability_id character varying NOT NULL,
    context_cpe_id uuid
);


--
-- Name: qualified_purl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qualified_purl (
    id uuid NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    versioned_purl_id uuid NOT NULL,
    qualifiers jsonb NOT NULL,
    purl jsonb
);


--
-- Name: relationship; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relationship (
    id integer NOT NULL,
    description character varying NOT NULL
);


--
-- Name: sbom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sbom (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    document_id character varying,
    published timestamp with time zone,
    authors character varying[],
    labels jsonb NOT NULL,
    source_document_id uuid,
    data_licenses text[] DEFAULT ARRAY[]::text[] NOT NULL
);


--
-- Name: sbom_external_node; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sbom_external_node (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    external_doc_ref character varying NOT NULL,
    external_node_ref character varying NOT NULL,
    external_type integer NOT NULL,
    target_sbom_id uuid,
    discriminator_type integer,
    discriminator_value character varying
);


--
-- Name: sbom_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sbom_file (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL
);


--
-- Name: sbom_node; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sbom_node (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    name character varying NOT NULL
);


--
-- Name: sbom_node_checksum; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sbom_node_checksum (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    type character varying NOT NULL,
    value character varying NOT NULL
);


--
-- Name: sbom_package; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sbom_package (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    version character varying
);


--
-- Name: sbom_package_cpe_ref; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sbom_package_cpe_ref (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    cpe_id uuid NOT NULL
);


--
-- Name: sbom_package_purl_ref; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sbom_package_purl_ref (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    qualified_purl_id uuid NOT NULL
);


--
-- Name: source_document; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_document (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sha256 character varying NOT NULL,
    sha384 character varying NOT NULL,
    sha512 character varying NOT NULL,
    size bigint DEFAULT 0,
    ingested timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.status (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug character varying NOT NULL,
    name character varying NOT NULL,
    description character varying
);


--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_preferences (
    user_id character varying NOT NULL,
    key character varying NOT NULL,
    revision uuid NOT NULL,
    data jsonb NOT NULL
);


--
-- Name: version_scheme; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_scheme (
    id character varying NOT NULL,
    name character varying NOT NULL,
    description character varying
);


--
-- Name: versioned_purl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versioned_purl (
    id uuid NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    base_purl_id uuid NOT NULL,
    version character varying NOT NULL
);


--
-- Name: vulnerability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vulnerability (
    "timestamp" timestamp with time zone DEFAULT now(),
    id character varying NOT NULL,
    title character varying,
    published timestamp with time zone,
    modified timestamp with time zone,
    withdrawn timestamp with time zone,
    cwes text[],
    reserved timestamp with time zone
);


--
-- Name: vulnerability_description; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vulnerability_description (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    lang character varying NOT NULL,
    description character varying NOT NULL,
    vulnerability_id character varying NOT NULL,
    advisory_id uuid NOT NULL
);


--
-- Name: weakness; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weakness (
    id text NOT NULL,
    description text NOT NULL,
    extended_description text,
    child_of text[],
    parent_of text[],
    starts_with text[],
    can_follow text[],
    can_precede text[],
    required_by text[],
    requires text[],
    can_also_be text[],
    peer_of text[]
);


--
-- Data for Name: advisory; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: advisory_vulnerability; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: base_purl; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cpe; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cpe_license_assertion; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cvss3; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cvss4; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: importer; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: importer_report; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: license; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.license VALUES ('45b80306-87e7-5625-bfb6-31e139d1f463', 'BSD Zero Clause License', '{0BSD}', NULL);
INSERT INTO public.license VALUES ('b1e984c7-ec10-5ba9-b536-b623c439330b', '3D Slicer License v1.0', '{3D-Slicer-1.0}', NULL);
INSERT INTO public.license VALUES ('24ed4366-74df-5c4c-8d44-6f8aed440bdd', 'Attribution Assurance License', '{AAL}', NULL);
INSERT INTO public.license VALUES ('bb8f5939-4aba-5950-a5bc-a224f376f38a', 'Abstyles License', '{Abstyles}', NULL);
INSERT INTO public.license VALUES ('d6e5e6ad-6b56-5931-b6d9-cbed508a3154', 'AdaCore Doc License', '{AdaCore-doc}', NULL);
INSERT INTO public.license VALUES ('a5ec537e-b7b1-573e-8313-6f096d0b58aa', 'Adobe Systems Incorporated Source Code License Agreement', '{Adobe-2006}', NULL);
INSERT INTO public.license VALUES ('1a90958c-b481-5db4-a1db-7c712d0e0496', 'Adobe Display PostScript License', '{Adobe-Display-PostScript}', NULL);
INSERT INTO public.license VALUES ('90247848-672b-5968-b4a9-637448e39217', 'Adobe Glyph List License', '{Adobe-Glyph}', NULL);
INSERT INTO public.license VALUES ('bcd4999c-52f3-5ead-a2c8-5be77ad9a9b9', 'Adobe Utopia Font License', '{Adobe-Utopia}', NULL);
INSERT INTO public.license VALUES ('fdfefea8-29ea-5237-9e05-9c73ae2e7cd2', 'Amazon Digital Services License', '{ADSL}', NULL);
INSERT INTO public.license VALUES ('38ca5d2b-8c48-5614-b139-3669a42f5280', 'Academic Free License v1.1', '{AFL-1.1}', NULL);
INSERT INTO public.license VALUES ('b8e9253d-06af-5cf3-955d-1b528795b031', 'Academic Free License v1.2', '{AFL-1.2}', NULL);
INSERT INTO public.license VALUES ('f1387e9e-c457-5eac-b949-39507064acf0', 'Academic Free License v2.0', '{AFL-2.0}', NULL);
INSERT INTO public.license VALUES ('69cc9f72-8fb1-5b8d-8c70-ca9fad95693f', 'Academic Free License v2.1', '{AFL-2.1}', NULL);
INSERT INTO public.license VALUES ('5bc9070e-73db-51d2-b660-51c653d694fd', 'Academic Free License v3.0', '{AFL-3.0}', NULL);
INSERT INTO public.license VALUES ('9075ba78-10fa-50f5-9f21-f94466f0b523', 'Afmparse License', '{Afmparse}', NULL);
INSERT INTO public.license VALUES ('8f844ae8-f6dd-560f-8990-cd2eff27596f', 'Affero General Public License v1.0', '{AGPL-1.0}', NULL);
INSERT INTO public.license VALUES ('795ddfb0-1305-5b17-b5fd-a6e06a33bc99', 'Affero General Public License v1.0 only', '{AGPL-1.0-only}', NULL);
INSERT INTO public.license VALUES ('56f98d4e-c312-51bc-89cf-8dcd0888d248', 'Affero General Public License v1.0 or later', '{AGPL-1.0-or-later}', NULL);
INSERT INTO public.license VALUES ('ed1acad4-5d93-53ab-8397-25a668148920', 'GNU Affero General Public License v3.0', '{AGPL-3.0}', NULL);
INSERT INTO public.license VALUES ('750ffd6d-4cfe-5481-9923-c66659136472', 'GNU Affero General Public License v3.0 only', '{AGPL-3.0-only}', NULL);
INSERT INTO public.license VALUES ('de411567-f657-5704-82ba-062daf570e93', 'GNU Affero General Public License v3.0 or later', '{AGPL-3.0-or-later}', NULL);
INSERT INTO public.license VALUES ('a2a32b1d-319c-5090-b8e9-2523da54495f', 'Aladdin Free Public License', '{Aladdin}', NULL);
INSERT INTO public.license VALUES ('cd9ac8c1-6402-5f89-993e-a1fff61bb38a', 'AMD newlib License', '{AMD-newlib}', NULL);
INSERT INTO public.license VALUES ('12e5967a-dc23-5c4e-9f9b-8931666e96c7', 'AMD''s plpa_map.c License', '{AMDPLPA}', NULL);
INSERT INTO public.license VALUES ('6bbb82e9-0d38-53e1-bb4c-f5e61cac8c94', 'Apple MIT License', '{AML}', NULL);
INSERT INTO public.license VALUES ('528587cc-1e13-580e-9d9a-3c83a1fc73ab', 'AML glslang variant License', '{AML-glslang}', NULL);
INSERT INTO public.license VALUES ('201757fd-76d3-54a2-a7f9-af5d4e1408c5', 'Academy of Motion Picture Arts and Sciences BSD', '{AMPAS}', NULL);
INSERT INTO public.license VALUES ('bd3c181a-b8ca-51b3-b8ed-70b3d80b7ec3', 'ANTLR Software Rights Notice', '{ANTLR-PD}', NULL);
INSERT INTO public.license VALUES ('22571801-e7a6-5e64-93d8-827aa17f7426', 'ANTLR Software Rights Notice with license fallback', '{ANTLR-PD-fallback}', NULL);
INSERT INTO public.license VALUES ('a38ddc42-2621-5044-ac16-0f3c876409df', 'Any OSI License', '{any-OSI}', NULL);
INSERT INTO public.license VALUES ('aae94317-f7b1-56d9-853f-f88622828547', 'Apache License 1.0', '{Apache-1.0}', NULL);
INSERT INTO public.license VALUES ('f6a10ed4-5679-5ee0-a418-f7a92c6dbf05', 'Apache License 1.1', '{Apache-1.1}', NULL);
INSERT INTO public.license VALUES ('db83bca7-813c-5c9f-93e2-9b4e6e6c13c9', 'Apache License 2.0', '{Apache-2.0}', NULL);
INSERT INTO public.license VALUES ('e94f3ce7-4350-5095-a375-54351952fbe8', 'Adobe Postscript AFM License', '{APAFML}', NULL);
INSERT INTO public.license VALUES ('4ccebbae-0ca9-5b81-ac69-7ac8411ef441', 'Adaptive Public License 1.0', '{APL-1.0}', NULL);
INSERT INTO public.license VALUES ('9be9e3d3-19e3-523c-b47e-75361274d8d3', 'App::s2p License', '{App-s2p}', NULL);
INSERT INTO public.license VALUES ('762b3b27-b8fd-5c89-b0b5-d0c51ac15708', 'Apple Public Source License 1.0', '{APSL-1.0}', NULL);
INSERT INTO public.license VALUES ('5b8b0c4e-9605-5763-9feb-2309aaacb93e', 'Apple Public Source License 1.1', '{APSL-1.1}', NULL);
INSERT INTO public.license VALUES ('af144695-0b8a-58e3-ae96-3c5b8a78fef3', 'Apple Public Source License 1.2', '{APSL-1.2}', NULL);
INSERT INTO public.license VALUES ('00ec7082-6a7c-59d5-8dc0-dd843df56687', 'Apple Public Source License 2.0', '{APSL-2.0}', NULL);
INSERT INTO public.license VALUES ('ac8f0499-38f9-59c6-a95b-0ed9a5efa3f8', 'Arphic Public License', '{Arphic-1999}', NULL);
INSERT INTO public.license VALUES ('9e4b5c5b-fd8f-5fd6-bc0a-004e311ff0db', 'Artistic License 1.0', '{Artistic-1.0}', NULL);
INSERT INTO public.license VALUES ('673e5422-b84b-52bf-8a4e-2f2b7512aabd', 'Artistic License 1.0 w/clause 8', '{Artistic-1.0-cl8}', NULL);
INSERT INTO public.license VALUES ('29a45009-7edb-5e10-91c8-abd3c14f57fc', 'Artistic License 1.0 (Perl)', '{Artistic-1.0-Perl}', NULL);
INSERT INTO public.license VALUES ('0fdbac01-c906-5ff9-a317-b139ea2f1fe1', 'Artistic License 2.0', '{Artistic-2.0}', NULL);
INSERT INTO public.license VALUES ('6ec1aaed-e378-5155-bff9-3112f1be56d5', 'ASWF Digital Assets License version 1.0', '{ASWF-Digital-Assets-1.0}', NULL);
INSERT INTO public.license VALUES ('18021bc1-ccd8-53d4-8988-2f903242205d', 'ASWF Digital Assets License 1.1', '{ASWF-Digital-Assets-1.1}', NULL);
INSERT INTO public.license VALUES ('a2334a79-c49d-5525-85a9-2f2b9e4334af', 'Baekmuk License', '{Baekmuk}', NULL);
INSERT INTO public.license VALUES ('1271c0e8-320c-5ce1-8302-85c3179f74de', 'Bahyph License', '{Bahyph}', NULL);
INSERT INTO public.license VALUES ('95679db1-12cd-56d7-a8c2-1927e6d17180', 'Barr License', '{Barr}', NULL);
INSERT INTO public.license VALUES ('1add9548-ee67-5f6b-8057-6ec3d47d9acf', 'bcrypt Solar Designer License', '{bcrypt-Solar-Designer}', NULL);
INSERT INTO public.license VALUES ('4d2598af-5c68-5fcb-9c0c-2c84d98624f5', 'Beerware License', '{Beerware}', NULL);
INSERT INTO public.license VALUES ('5c22f12d-58ef-5adb-b8f2-de1567d8ec3a', 'Bitstream Charter Font License', '{Bitstream-Charter}', NULL);
INSERT INTO public.license VALUES ('c565dd92-e6dc-592a-ba16-23af601f7f64', 'Bitstream Vera Font License', '{Bitstream-Vera}', NULL);
INSERT INTO public.license VALUES ('dffecd89-c107-5724-94ef-360242d91eb6', 'BitTorrent Open Source License v1.0', '{BitTorrent-1.0}', NULL);
INSERT INTO public.license VALUES ('6d3a35ba-f96c-5b16-84d9-5b57100d969e', 'BitTorrent Open Source License v1.1', '{BitTorrent-1.1}', NULL);
INSERT INTO public.license VALUES ('919357fa-8d14-5e7c-a810-91876b8b36f6', 'SQLite Blessing', '{blessing}', NULL);
INSERT INTO public.license VALUES ('c0fde98e-3fc8-507e-a310-0dc600e6490f', 'Blue Oak Model License 1.0.0', '{BlueOak-1.0.0}', NULL);
INSERT INTO public.license VALUES ('0f85c94f-8568-53ae-80c6-a3a3716a4089', 'Boehm-Demers-Weiser GC License', '{Boehm-GC}', NULL);
INSERT INTO public.license VALUES ('277820ea-5d2f-5d67-b6eb-6e7e18ee8df3', 'Borceux license', '{Borceux}', NULL);
INSERT INTO public.license VALUES ('50e926da-d116-5386-9688-2fa1ec855215', 'Brian Gladman 2-Clause License', '{Brian-Gladman-2-Clause}', NULL);
INSERT INTO public.license VALUES ('d74ebef9-9049-5a2d-af08-e84ed2277938', 'Brian Gladman 3-Clause License', '{Brian-Gladman-3-Clause}', NULL);
INSERT INTO public.license VALUES ('1048a598-0264-5061-bb15-ab58715d499c', 'BSD 1-Clause License', '{BSD-1-Clause}', NULL);
INSERT INTO public.license VALUES ('e9ebac1b-c75f-58df-afd9-59b9600784a1', 'BSD 2-Clause "Simplified" License', '{BSD-2-Clause}', NULL);
INSERT INTO public.license VALUES ('313379cc-b832-5b63-b075-67166e2df7b2', 'BSD 2-Clause - Ian Darwin variant', '{BSD-2-Clause-Darwin}', NULL);
INSERT INTO public.license VALUES ('bfa418e4-30fc-5c3a-a4d1-17f865212ac0', 'BSD 2-Clause - first lines requirement', '{BSD-2-Clause-first-lines}', NULL);
INSERT INTO public.license VALUES ('45e45149-56f7-5120-95be-38ba3cad0c66', 'BSD 2-Clause FreeBSD License', '{BSD-2-Clause-FreeBSD}', NULL);
INSERT INTO public.license VALUES ('34b7ae08-99e9-5275-b6b9-c5c8c7387dc4', 'BSD 2-Clause NetBSD License', '{BSD-2-Clause-NetBSD}', NULL);
INSERT INTO public.license VALUES ('9a0941fd-fb10-5be3-b2a0-4530bd501aee', 'BSD-2-Clause Plus Patent License', '{BSD-2-Clause-Patent}', NULL);
INSERT INTO public.license VALUES ('0f638dde-47f0-5b5f-960f-10a92dce2157', 'BSD 2-Clause with views sentence', '{BSD-2-Clause-Views}', NULL);
INSERT INTO public.license VALUES ('f2b76f21-e7f2-5028-a591-c901e9a86675', 'BSD 3-Clause "New" or "Revised" License', '{BSD-3-Clause}', NULL);
INSERT INTO public.license VALUES ('00cfbc56-9afb-5b1b-9629-b666a1a8585b', 'BSD 3-Clause acpica variant', '{BSD-3-Clause-acpica}', NULL);
INSERT INTO public.license VALUES ('b6b153b5-57f3-5681-bb2e-aaecd7e6b9d8', 'BSD with attribution', '{BSD-3-Clause-Attribution}', NULL);
INSERT INTO public.license VALUES ('70b01dcf-b066-5585-93bc-c1430fd703d2', 'BSD 3-Clause Clear License', '{BSD-3-Clause-Clear}', NULL);
INSERT INTO public.license VALUES ('cedab029-2af4-57a9-adb8-79949409809d', 'BSD 3-Clause Flex variant', '{BSD-3-Clause-flex}', NULL);
INSERT INTO public.license VALUES ('8deafe9d-ce24-5d72-bc73-dbd1297ade69', 'Hewlett-Packard BSD variant license', '{BSD-3-Clause-HP}', NULL);
INSERT INTO public.license VALUES ('4fa500a4-6c12-57ab-a468-92018600ff7d', 'Lawrence Berkeley National Labs BSD variant license', '{BSD-3-Clause-LBNL}', NULL);
INSERT INTO public.license VALUES ('d2418616-6a3d-51f2-a49b-2a7b810ee99b', 'BSD 3-Clause Modification', '{BSD-3-Clause-Modification}', NULL);
INSERT INTO public.license VALUES ('c3e9e778-3523-5926-8f73-988f736e5fa4', 'BSD 3-Clause No Military License', '{BSD-3-Clause-No-Military-License}', NULL);
INSERT INTO public.license VALUES ('267e4a12-6886-5ee9-93a3-3ae9a6be1c91', 'BSD 3-Clause No Nuclear License', '{BSD-3-Clause-No-Nuclear-License}', NULL);
INSERT INTO public.license VALUES ('6a8b91e7-30df-53d9-bb21-9b8a9208cbae', 'BSD 3-Clause No Nuclear License 2014', '{BSD-3-Clause-No-Nuclear-License-2014}', NULL);
INSERT INTO public.license VALUES ('a465d345-f0c5-56d4-9798-6be2065c03c6', 'BSD 3-Clause No Nuclear Warranty', '{BSD-3-Clause-No-Nuclear-Warranty}', NULL);
INSERT INTO public.license VALUES ('86d1b723-43e9-5269-b89e-4bad1f3e4677', 'BSD 3-Clause Open MPI variant', '{BSD-3-Clause-Open-MPI}', NULL);
INSERT INTO public.license VALUES ('a0380d5f-66d3-57d4-bc95-dca638178c4e', 'BSD 3-Clause Sun Microsystems', '{BSD-3-Clause-Sun}', NULL);
INSERT INTO public.license VALUES ('4e9199d5-5664-5dda-97d9-c92206b811a5', 'BSD 4-Clause "Original" or "Old" License', '{BSD-4-Clause}', NULL);
INSERT INTO public.license VALUES ('ef06d36a-bd18-5b5e-8161-b6030d6b2344', 'BSD 4 Clause Shortened', '{BSD-4-Clause-Shortened}', NULL);
INSERT INTO public.license VALUES ('5f913393-123a-5508-a642-06a72eeab519', 'BSD-4-Clause (University of California-Specific)', '{BSD-4-Clause-UC}', NULL);
INSERT INTO public.license VALUES ('f8ac76ed-96db-55d4-81cd-f68eaf831baa', 'BSD 4.3 RENO License', '{BSD-4.3RENO}', NULL);
INSERT INTO public.license VALUES ('1e70134a-e051-5844-b8ae-170a699cfff3', 'BSD 4.3 TAHOE License', '{BSD-4.3TAHOE}', NULL);
INSERT INTO public.license VALUES ('825eabeb-7ddf-5918-9791-9ae45ac73550', 'BSD Advertising Acknowledgement License', '{BSD-Advertising-Acknowledgement}', NULL);
INSERT INTO public.license VALUES ('a727a941-253f-5b5f-8d92-d84ef3c2169e', 'BSD with Attribution and HPND disclaimer', '{BSD-Attribution-HPND-disclaimer}', NULL);
INSERT INTO public.license VALUES ('a2fb756d-55b9-57ee-b7e5-f2a863938d8a', 'BSD-Inferno-Nettverk', '{BSD-Inferno-Nettverk}', NULL);
INSERT INTO public.license VALUES ('5bf95bb5-2555-5591-8122-9e7b5aad590c', 'BSD Protection License', '{BSD-Protection}', NULL);
INSERT INTO public.license VALUES ('d6cfe69b-c35b-5c2d-b333-785429d722a0', 'BSD Source Code Attribution - beginning of file variant', '{BSD-Source-beginning-file}', NULL);
INSERT INTO public.license VALUES ('63b6914e-2e76-574f-bcd9-acab2ba963d3', 'BSD Source Code Attribution', '{BSD-Source-Code}', NULL);
INSERT INTO public.license VALUES ('547d8141-1e2a-5377-ad20-e3e6425985a5', 'Systemics BSD variant license', '{BSD-Systemics}', NULL);
INSERT INTO public.license VALUES ('44e15a5a-2852-58e2-ac20-ebd628dfab59', 'Systemics W3Works BSD variant license', '{BSD-Systemics-W3Works}', NULL);
INSERT INTO public.license VALUES ('f9fc117e-48ff-5b85-b359-99c24907de46', 'Boost Software License 1.0', '{BSL-1.0}', NULL);
INSERT INTO public.license VALUES ('552e5a57-d3ae-58e3-8fe6-6b50a39d18f4', 'Business Source License 1.1', '{BUSL-1.1}', NULL);
INSERT INTO public.license VALUES ('34bfbd75-20c0-5ca9-8a6d-84284d0d0823', 'bzip2 and libbzip2 License v1.0.5', '{bzip2-1.0.5}', NULL);
INSERT INTO public.license VALUES ('98c77c05-3ebf-5da9-9cc3-9ead669f7ce9', 'bzip2 and libbzip2 License v1.0.6', '{bzip2-1.0.6}', NULL);
INSERT INTO public.license VALUES ('0eaee8c4-1e1d-542d-9b89-ca458dae9c28', 'Computational Use of Data Agreement v1.0', '{C-UDA-1.0}', NULL);
INSERT INTO public.license VALUES ('583e99f8-3295-5269-a09f-c21592f2e285', 'Cryptographic Autonomy License 1.0', '{CAL-1.0}', NULL);
INSERT INTO public.license VALUES ('5611d98b-1ffb-55eb-8917-2bbf3cdf002e', 'Cryptographic Autonomy License 1.0 (Combined Work Exception)', '{CAL-1.0-Combined-Work-Exception}', NULL);
INSERT INTO public.license VALUES ('3a2a09e9-1ec4-5442-981c-16864a38ffa9', 'Caldera License', '{Caldera}', NULL);
INSERT INTO public.license VALUES ('275669c3-1163-569a-a18a-be31ce623bd8', 'Caldera License (without preamble)', '{Caldera-no-preamble}', NULL);
INSERT INTO public.license VALUES ('b8ae14a8-9065-5eb5-853a-364cb7fe6b45', 'Catharon License', '{Catharon}', NULL);
INSERT INTO public.license VALUES ('751cfc86-fb46-59f3-901d-1ac94b028312', 'Computer Associates Trusted Open Source License 1.1', '{CATOSL-1.1}', NULL);
INSERT INTO public.license VALUES ('6ff1243b-f641-5090-addc-4474e562228d', 'Creative Commons Attribution 1.0 Generic', '{CC-BY-1.0}', NULL);
INSERT INTO public.license VALUES ('8db1885d-2f79-5a3d-9584-10b92b689fae', 'Creative Commons Attribution 2.0 Generic', '{CC-BY-2.0}', NULL);
INSERT INTO public.license VALUES ('d00f178f-1ba6-5694-b251-bd0d712ce6c7', 'Creative Commons Attribution 2.5 Generic', '{CC-BY-2.5}', NULL);
INSERT INTO public.license VALUES ('a8e5ae00-30b8-5762-90c8-2c209aead737', 'Creative Commons Attribution 2.5 Australia', '{CC-BY-2.5-AU}', NULL);
INSERT INTO public.license VALUES ('19cac76b-656a-53d2-b67c-6954f911401e', 'Creative Commons Attribution 3.0 Unported', '{CC-BY-3.0}', NULL);
INSERT INTO public.license VALUES ('d540f970-9b9d-5028-b50e-9a7df0ffcbed', 'Creative Commons Attribution 3.0 Austria', '{CC-BY-3.0-AT}', NULL);
INSERT INTO public.license VALUES ('c7dd6930-3cee-5f33-ac73-8e0e6919f7fd', 'Creative Commons Attribution 3.0 Australia', '{CC-BY-3.0-AU}', NULL);
INSERT INTO public.license VALUES ('b050c6a1-f756-55c7-a567-00f67b4fc194', 'Creative Commons Attribution 3.0 Germany', '{CC-BY-3.0-DE}', NULL);
INSERT INTO public.license VALUES ('c3398da2-27fe-5e13-b573-0afc3be3a891', 'Creative Commons Attribution 3.0 IGO', '{CC-BY-3.0-IGO}', NULL);
INSERT INTO public.license VALUES ('d70ca1cc-b7ff-5baa-9781-77c7c0e26d6e', 'Creative Commons Attribution 3.0 Netherlands', '{CC-BY-3.0-NL}', NULL);
INSERT INTO public.license VALUES ('5b751f19-6d2d-5358-a46a-84fd64afd10d', 'Creative Commons Attribution 3.0 United States', '{CC-BY-3.0-US}', NULL);
INSERT INTO public.license VALUES ('7b32769e-74f9-595f-824e-80471db9a8d8', 'Creative Commons Attribution 4.0 International', '{CC-BY-4.0}', NULL);
INSERT INTO public.license VALUES ('ec440e47-7691-5a13-a955-2a4deb670dea', 'Creative Commons Attribution Non Commercial 1.0 Generic', '{CC-BY-NC-1.0}', NULL);
INSERT INTO public.license VALUES ('7f78edf9-5b76-5493-96df-8ae75de37c3f', 'Creative Commons Attribution Non Commercial 2.0 Generic', '{CC-BY-NC-2.0}', NULL);
INSERT INTO public.license VALUES ('aa9995f3-d550-5849-a0b8-e5e11bab2dcf', 'Creative Commons Attribution Non Commercial 2.5 Generic', '{CC-BY-NC-2.5}', NULL);
INSERT INTO public.license VALUES ('944737a3-4266-546c-98bc-9848c1918f42', 'Creative Commons Attribution Non Commercial 3.0 Unported', '{CC-BY-NC-3.0}', NULL);
INSERT INTO public.license VALUES ('9db74e0c-bcf2-58bf-8d12-a94ba0a8e2d3', 'Creative Commons Attribution Non Commercial 3.0 Germany', '{CC-BY-NC-3.0-DE}', NULL);
INSERT INTO public.license VALUES ('f82dc47a-7c5e-5a33-a2fa-bfa5f7926892', 'Creative Commons Attribution Non Commercial 4.0 International', '{CC-BY-NC-4.0}', NULL);
INSERT INTO public.license VALUES ('63321c1b-cb03-5b3d-844e-225ebb61e86b', 'Creative Commons Attribution Non Commercial No Derivatives 1.0 Generic', '{CC-BY-NC-ND-1.0}', NULL);
INSERT INTO public.license VALUES ('4b5e395c-20cc-5bc5-9288-1cf54948585a', 'Creative Commons Attribution Non Commercial No Derivatives 2.0 Generic', '{CC-BY-NC-ND-2.0}', NULL);
INSERT INTO public.license VALUES ('b37107f3-68d8-5096-a949-506356ecaa1a', 'Creative Commons Attribution Non Commercial No Derivatives 2.5 Generic', '{CC-BY-NC-ND-2.5}', NULL);
INSERT INTO public.license VALUES ('6f2af035-39ee-5492-aea0-e6efdc0e419a', 'Creative Commons Attribution Non Commercial No Derivatives 3.0 Unported', '{CC-BY-NC-ND-3.0}', NULL);
INSERT INTO public.license VALUES ('34abacd4-6539-5285-b7f3-90ac18f8c4d2', 'Creative Commons Attribution Non Commercial No Derivatives 3.0 Germany', '{CC-BY-NC-ND-3.0-DE}', NULL);
INSERT INTO public.license VALUES ('b127b286-7750-56be-838b-df59b988f493', 'Creative Commons Attribution Non Commercial No Derivatives 3.0 IGO', '{CC-BY-NC-ND-3.0-IGO}', NULL);
INSERT INTO public.license VALUES ('37bed154-0845-57b0-8c16-52fd61e28f70', 'Creative Commons Attribution Non Commercial No Derivatives 4.0 International', '{CC-BY-NC-ND-4.0}', NULL);
INSERT INTO public.license VALUES ('b8325138-8ccd-54f9-a031-ada98f129fa3', 'Creative Commons Attribution Non Commercial Share Alike 1.0 Generic', '{CC-BY-NC-SA-1.0}', NULL);
INSERT INTO public.license VALUES ('ca0d1839-54bb-5ca2-a2d4-bff1b8651794', 'Creative Commons Attribution Non Commercial Share Alike 2.0 Generic', '{CC-BY-NC-SA-2.0}', NULL);
INSERT INTO public.license VALUES ('859ebda2-f2f7-584c-b609-fe70ce668661', 'Creative Commons Attribution Non Commercial Share Alike 2.0 Germany', '{CC-BY-NC-SA-2.0-DE}', NULL);
INSERT INTO public.license VALUES ('7a5a1209-64ca-59c2-b052-71a59301cb4e', 'Creative Commons Attribution-NonCommercial-ShareAlike 2.0 France', '{CC-BY-NC-SA-2.0-FR}', NULL);
INSERT INTO public.license VALUES ('9f915a8d-28dc-5e0e-8044-fb50e8bf1d1f', 'Creative Commons Attribution Non Commercial Share Alike 2.0 England and Wales', '{CC-BY-NC-SA-2.0-UK}', NULL);
INSERT INTO public.license VALUES ('a884be17-d050-5885-8aae-1391c0e57d2d', 'Creative Commons Attribution Non Commercial Share Alike 2.5 Generic', '{CC-BY-NC-SA-2.5}', NULL);
INSERT INTO public.license VALUES ('e9dc5b48-22f4-5da0-9a37-496fa592d088', 'Creative Commons Attribution Non Commercial Share Alike 3.0 Unported', '{CC-BY-NC-SA-3.0}', NULL);
INSERT INTO public.license VALUES ('bfa28d09-e7c8-562a-8e3a-3a78bd6f5585', 'Creative Commons Attribution Non Commercial Share Alike 3.0 Germany', '{CC-BY-NC-SA-3.0-DE}', NULL);
INSERT INTO public.license VALUES ('eb255755-40e6-52d0-8e83-a860d2cc4795', 'Creative Commons Attribution Non Commercial Share Alike 3.0 IGO', '{CC-BY-NC-SA-3.0-IGO}', NULL);
INSERT INTO public.license VALUES ('ebb39019-48be-5f4d-843c-ec52639f189b', 'Creative Commons Attribution Non Commercial Share Alike 4.0 International', '{CC-BY-NC-SA-4.0}', NULL);
INSERT INTO public.license VALUES ('dcfa7678-ada2-5771-87b6-26c53ef20727', 'Creative Commons Attribution No Derivatives 1.0 Generic', '{CC-BY-ND-1.0}', NULL);
INSERT INTO public.license VALUES ('3749bec9-05c5-58dd-a123-c65dd54f5a6a', 'Creative Commons Attribution No Derivatives 2.0 Generic', '{CC-BY-ND-2.0}', NULL);
INSERT INTO public.license VALUES ('020d1f2a-53e3-5adc-a121-02703cad488a', 'Creative Commons Attribution No Derivatives 2.5 Generic', '{CC-BY-ND-2.5}', NULL);
INSERT INTO public.license VALUES ('e588925a-ee26-57bf-a3b9-c0e2aca2a28e', 'Creative Commons Attribution No Derivatives 3.0 Unported', '{CC-BY-ND-3.0}', NULL);
INSERT INTO public.license VALUES ('00f720be-405b-591a-b18e-ff0f184949fe', 'Creative Commons Attribution No Derivatives 3.0 Germany', '{CC-BY-ND-3.0-DE}', NULL);
INSERT INTO public.license VALUES ('b0cd9b46-56aa-5849-afd8-ee743415690b', 'Creative Commons Attribution No Derivatives 4.0 International', '{CC-BY-ND-4.0}', NULL);
INSERT INTO public.license VALUES ('71fc5022-7e97-5ffe-9778-0d287ff64a5b', 'Creative Commons Attribution Share Alike 1.0 Generic', '{CC-BY-SA-1.0}', NULL);
INSERT INTO public.license VALUES ('cd2b1d9c-e904-5ea5-bb50-765ffc56cc42', 'Creative Commons Attribution Share Alike 2.0 Generic', '{CC-BY-SA-2.0}', NULL);
INSERT INTO public.license VALUES ('fee9f1ff-ee54-5df5-bf04-d4c90dc94071', 'Creative Commons Attribution Share Alike 2.0 England and Wales', '{CC-BY-SA-2.0-UK}', NULL);
INSERT INTO public.license VALUES ('ed836b94-1241-5a51-862a-833bbc1338c6', 'Creative Commons Attribution Share Alike 2.1 Japan', '{CC-BY-SA-2.1-JP}', NULL);
INSERT INTO public.license VALUES ('65ff5bba-71be-5e86-ba7e-b38876f42d7d', 'Creative Commons Attribution Share Alike 2.5 Generic', '{CC-BY-SA-2.5}', NULL);
INSERT INTO public.license VALUES ('43954a59-5362-5a08-9cbe-39ddceb94b13', 'Creative Commons Attribution Share Alike 3.0 Unported', '{CC-BY-SA-3.0}', NULL);
INSERT INTO public.license VALUES ('e71fa805-36e7-526b-8e5f-c342f0a73a55', 'Creative Commons Attribution Share Alike 3.0 Austria', '{CC-BY-SA-3.0-AT}', NULL);
INSERT INTO public.license VALUES ('93723f9b-e34b-5a9b-8651-7c1737673625', 'Creative Commons Attribution Share Alike 3.0 Germany', '{CC-BY-SA-3.0-DE}', NULL);
INSERT INTO public.license VALUES ('98e1b738-cacd-5f00-a8f3-07e254ab58cf', 'Creative Commons Attribution-ShareAlike 3.0 IGO', '{CC-BY-SA-3.0-IGO}', NULL);
INSERT INTO public.license VALUES ('2e676261-6210-5dad-b8b6-13a9bb71de8a', 'Creative Commons Attribution Share Alike 4.0 International', '{CC-BY-SA-4.0}', NULL);
INSERT INTO public.license VALUES ('42977065-b1c9-5a34-89dd-25d77433564e', 'Creative Commons Public Domain Dedication and Certification', '{CC-PDDC}', NULL);
INSERT INTO public.license VALUES ('b07ff354-942f-5235-8df6-a65c7963bfb9', 'Creative Commons Zero v1.0 Universal', '{CC0-1.0}', NULL);
INSERT INTO public.license VALUES ('6b161561-01ea-5e4d-ace3-a6ca15f4cddd', 'Common Development and Distribution License 1.0', '{CDDL-1.0}', NULL);
INSERT INTO public.license VALUES ('60deddd6-8930-5bc4-8923-14cd2cc37ba9', 'Common Development and Distribution License 1.1', '{CDDL-1.1}', NULL);
INSERT INTO public.license VALUES ('9f147189-e035-5b6a-9167-0adb43bdb1b6', 'Common Documentation License 1.0', '{CDL-1.0}', NULL);
INSERT INTO public.license VALUES ('e74f4725-a1e8-5347-97d0-d687eae5b534', 'Community Data License Agreement Permissive 1.0', '{CDLA-Permissive-1.0}', NULL);
INSERT INTO public.license VALUES ('f6dd914b-05d6-50b8-b4a2-cbce91efac82', 'Community Data License Agreement Permissive 2.0', '{CDLA-Permissive-2.0}', NULL);
INSERT INTO public.license VALUES ('7540978e-ef43-5942-aed3-4f2814dc63e5', 'Community Data License Agreement Sharing 1.0', '{CDLA-Sharing-1.0}', NULL);
INSERT INTO public.license VALUES ('59aa73b2-c60d-5a35-b94d-6a1f149ae7bb', 'CeCILL Free Software License Agreement v1.0', '{CECILL-1.0}', NULL);
INSERT INTO public.license VALUES ('95d3f1a4-d1e7-5ee5-8347-a22d2fb28b4e', 'CeCILL Free Software License Agreement v1.1', '{CECILL-1.1}', NULL);
INSERT INTO public.license VALUES ('0f205439-f72f-5e07-bec3-1aeda88154eb', 'CeCILL Free Software License Agreement v2.0', '{CECILL-2.0}', NULL);
INSERT INTO public.license VALUES ('cd8c6211-28dc-552c-91ff-6782896ae0db', 'CeCILL Free Software License Agreement v2.1', '{CECILL-2.1}', NULL);
INSERT INTO public.license VALUES ('dcd88bbf-a5ad-5880-a466-d1da62e3e710', 'CeCILL-B Free Software License Agreement', '{CECILL-B}', NULL);
INSERT INTO public.license VALUES ('9265b673-caa3-527c-a5b7-472d351d1899', 'CeCILL-C Free Software License Agreement', '{CECILL-C}', NULL);
INSERT INTO public.license VALUES ('dbd1bab1-3163-541e-941f-ae8f03e96c22', 'CERN Open Hardware Licence v1.1', '{CERN-OHL-1.1}', NULL);
INSERT INTO public.license VALUES ('8bddb279-1047-5261-a3b3-d0cd9b354a81', 'CERN Open Hardware Licence v1.2', '{CERN-OHL-1.2}', NULL);
INSERT INTO public.license VALUES ('de53ce10-051c-5aea-aaf7-bcdc4a2f582d', 'CERN Open Hardware Licence Version 2 - Permissive', '{CERN-OHL-P-2.0}', NULL);
INSERT INTO public.license VALUES ('e41729d9-a1da-5aba-840c-2ab05cd3c91e', 'CERN Open Hardware Licence Version 2 - Strongly Reciprocal', '{CERN-OHL-S-2.0}', NULL);
INSERT INTO public.license VALUES ('1f50e58f-ede1-5c64-8c4e-494e7de5dc3d', 'CERN Open Hardware Licence Version 2 - Weakly Reciprocal', '{CERN-OHL-W-2.0}', NULL);
INSERT INTO public.license VALUES ('d0b1b310-d1ca-542f-933a-7530a5615fef', 'CFITSIO License', '{CFITSIO}', NULL);
INSERT INTO public.license VALUES ('a88234db-f762-5459-b7f9-01456a727a16', 'check-cvs License', '{check-cvs}', NULL);
INSERT INTO public.license VALUES ('945179a9-a4da-562a-badd-d9c129703f69', 'Checkmk License', '{checkmk}', NULL);
INSERT INTO public.license VALUES ('0f35af2d-4362-5fce-ba7c-c075e1df3c81', 'Clarified Artistic License', '{ClArtistic}', NULL);
INSERT INTO public.license VALUES ('1e956a8a-4a87-57c6-a770-61063977bea9', 'Clips License', '{Clips}', NULL);
INSERT INTO public.license VALUES ('73ca85da-2b67-5704-9753-324c6cbc58a3', 'CMU Mach License', '{CMU-Mach}', NULL);
INSERT INTO public.license VALUES ('d15fca3d-e19d-54e2-929f-f9286eb315c4', 'CMU    Mach - no notices-in-documentation variant', '{CMU-Mach-nodoc}', NULL);
INSERT INTO public.license VALUES ('6a99e181-e461-5281-8a11-3b77bc5ebea5', 'CNRI Jython License', '{CNRI-Jython}', NULL);
INSERT INTO public.license VALUES ('55047df3-ad19-5da4-90ad-b11ed2bb0051', 'CNRI Python License', '{CNRI-Python}', NULL);
INSERT INTO public.license VALUES ('f6988a8b-3124-542a-9679-8ffa1522b3af', 'CNRI Python Open Source GPL Compatible License Agreement', '{CNRI-Python-GPL-Compatible}', NULL);
INSERT INTO public.license VALUES ('515e2102-056c-548a-a1ee-0413c33c6d90', 'Copyfree Open Innovation License', '{COIL-1.0}', NULL);
INSERT INTO public.license VALUES ('8b32757d-4d36-519d-9d98-93dc5dedf682', 'Community Specification License 1.0', '{Community-Spec-1.0}', NULL);
INSERT INTO public.license VALUES ('36853b3a-f686-56af-882e-91753c611ed6', 'Condor Public License v1.1', '{Condor-1.1}', NULL);
INSERT INTO public.license VALUES ('de387418-14ad-56cd-8740-723b37e3c46a', 'copyleft-next 0.3.0', '{copyleft-next-0.3.0}', NULL);
INSERT INTO public.license VALUES ('11e271dc-5c2e-5321-819e-4840de093e47', 'copyleft-next 0.3.1', '{copyleft-next-0.3.1}', NULL);
INSERT INTO public.license VALUES ('66b84d72-6e6f-573a-825a-29a34a066a57', 'Cornell Lossless JPEG License', '{Cornell-Lossless-JPEG}', NULL);
INSERT INTO public.license VALUES ('f4177d9f-5119-508e-b984-00191b6c06d4', 'Common Public Attribution License 1.0', '{CPAL-1.0}', NULL);
INSERT INTO public.license VALUES ('ab5fbf44-d401-5247-a86e-a37b6d30064e', 'Common Public License 1.0', '{CPL-1.0}', NULL);
INSERT INTO public.license VALUES ('e3fb7516-9972-5b2f-b18e-3fe504234442', 'Code Project Open License 1.02', '{CPOL-1.02}', NULL);
INSERT INTO public.license VALUES ('96cfba97-fcc2-5877-8b3f-d53933d2c26e', 'Cronyx License', '{Cronyx}', NULL);
INSERT INTO public.license VALUES ('a258eb20-96a8-5ee1-8087-89bb19034386', 'Crossword License', '{Crossword}', NULL);
INSERT INTO public.license VALUES ('6a8628b1-bcbe-598a-89f7-42b21a0890ac', 'CrystalStacker License', '{CrystalStacker}', NULL);
INSERT INTO public.license VALUES ('13f117f9-e588-5769-a6de-3e9598d22f58', 'CUA Office Public License v1.0', '{CUA-OPL-1.0}', NULL);
INSERT INTO public.license VALUES ('c77bacf3-2b98-574b-aa6e-ce949ea81791', 'Cube License', '{Cube}', NULL);
INSERT INTO public.license VALUES ('a48b894e-2a06-5ba8-bca3-596c257d9781', 'curl License', '{curl}', NULL);
INSERT INTO public.license VALUES ('782c130c-2094-590d-a0a0-6fa95bb89102', 'Common Vulnerability Enumeration ToU License', '{cve-tou}', NULL);
INSERT INTO public.license VALUES ('e821424e-e12b-5d4b-8520-3f0025f8959d', 'Deutsche Freie Software Lizenz', '{D-FSL-1.0}', NULL);
INSERT INTO public.license VALUES ('825dca96-3046-5940-a32c-540f9b533d39', 'DEC 3-Clause License', '{DEC-3-Clause}', NULL);
INSERT INTO public.license VALUES ('18ddbf4b-dc4e-56ac-ba72-5d37c6c04497', 'diffmark license', '{diffmark}', NULL);
INSERT INTO public.license VALUES ('b8838e1c-f53a-5a59-81e7-b34959abcc4c', 'Data licence Germany – attribution – version 2.0', '{DL-DE-BY-2.0}', NULL);
INSERT INTO public.license VALUES ('c26e6dba-d48f-5001-a5ea-4c4a04be7aad', 'Data licence Germany – zero – version 2.0', '{DL-DE-ZERO-2.0}', NULL);
INSERT INTO public.license VALUES ('eba58b6e-71e1-5cb9-b302-87f5866cbbae', 'DOC License', '{DOC}', NULL);
INSERT INTO public.license VALUES ('e51ea763-1c13-53a2-97f3-ab54d36d6c62', 'DocBook Schema License', '{DocBook-Schema}', NULL);
INSERT INTO public.license VALUES ('a86812f5-cc96-5156-a1b8-e8d75827b193', 'DocBook XML License', '{DocBook-XML}', NULL);
INSERT INTO public.license VALUES ('cc66d90c-e6c8-5f77-9e30-98c9a41eebf6', 'Dotseqn License', '{Dotseqn}', NULL);
INSERT INTO public.license VALUES ('6808cc72-9f67-5975-934d-c2b1181a4b58', 'Detection Rule License 1.0', '{DRL-1.0}', NULL);
INSERT INTO public.license VALUES ('0b7dd922-a4af-5834-896c-0a2277c6853b', 'Detection Rule License 1.1', '{DRL-1.1}', NULL);
INSERT INTO public.license VALUES ('6fc80b48-5612-5c11-8195-5bcf0416ba58', 'DSDP License', '{DSDP}', NULL);
INSERT INTO public.license VALUES ('f1095c72-ba1c-58a6-b58d-341fd2e351d2', 'David M. Gay dtoa License', '{dtoa}', NULL);
INSERT INTO public.license VALUES ('f063b650-39a2-5b76-bb38-7b6e8e7b37f4', 'dvipdfm License', '{dvipdfm}', NULL);
INSERT INTO public.license VALUES ('8dfaae27-04e1-50d5-a9ff-16de9750e58a', 'Educational Community License v1.0', '{ECL-1.0}', NULL);
INSERT INTO public.license VALUES ('d5baa3ee-cad7-58d4-943a-a266e4f3b536', 'Educational Community License v2.0', '{ECL-2.0}', NULL);
INSERT INTO public.license VALUES ('ad736fd3-f62c-52e2-a392-2ff718b016ec', 'eCos license version 2.0', '{eCos-2.0}', NULL);
INSERT INTO public.license VALUES ('551e864a-9452-51df-a85b-697f1495bc04', 'Eiffel Forum License v1.0', '{EFL-1.0}', NULL);
INSERT INTO public.license VALUES ('c13b2a2d-d4ee-50ad-ad3b-8ea17e1aad89', 'Eiffel Forum License v2.0', '{EFL-2.0}', NULL);
INSERT INTO public.license VALUES ('49448f5f-4954-56c0-94d3-902af886b4a6', 'eGenix.com Public License 1.1.0', '{eGenix}', NULL);
INSERT INTO public.license VALUES ('e12fd6d6-4b1e-5fae-9312-3744a480f383', 'Elastic License 2.0', '{Elastic-2.0}', NULL);
INSERT INTO public.license VALUES ('903e3946-d3e5-5f80-8464-33571da93a5d', 'Entessa Public License v1.0', '{Entessa}', NULL);
INSERT INTO public.license VALUES ('31075bad-c4d2-5b44-8ceb-45f4c552f375', 'EPICS Open License', '{EPICS}', NULL);
INSERT INTO public.license VALUES ('eb1af085-c0c7-58f3-95fb-052e2e5bcf46', 'Eclipse Public License 1.0', '{EPL-1.0}', NULL);
INSERT INTO public.license VALUES ('fafc3ff5-b8da-5cdd-8543-09b6139caa8b', 'Eclipse Public License 2.0', '{EPL-2.0}', NULL);
INSERT INTO public.license VALUES ('885c1d46-58da-5abf-bcd0-64a4c18f65b1', 'Erlang Public License v1.1', '{ErlPL-1.1}', NULL);
INSERT INTO public.license VALUES ('6abecd48-42a8-5984-94dc-3fdc7d0bd231', 'Etalab Open License 2.0', '{etalab-2.0}', NULL);
INSERT INTO public.license VALUES ('0f2a0549-37ce-5965-9bfd-d1ae6d5ea37d', 'EU DataGrid Software License', '{EUDatagrid}', NULL);
INSERT INTO public.license VALUES ('81ce17d8-97cf-5900-ba9d-efd24d5cef10', 'European Union Public License 1.0', '{EUPL-1.0}', NULL);
INSERT INTO public.license VALUES ('257e2d24-a8be-56ca-b196-1e276949f2cb', 'European Union Public License 1.1', '{EUPL-1.1}', NULL);
INSERT INTO public.license VALUES ('ce204668-6440-5ef9-8159-b987f139e238', 'European Union Public License 1.2', '{EUPL-1.2}', NULL);
INSERT INTO public.license VALUES ('9178e9d5-534f-50bf-93d8-7d54fba54cbe', 'Eurosym License', '{Eurosym}', NULL);
INSERT INTO public.license VALUES ('fd3a14f5-626f-5b0d-930f-4a6d8058d5ea', 'Fair License', '{Fair}', NULL);
INSERT INTO public.license VALUES ('64d69eeb-b206-5f62-91fd-7fba884c4535', 'Fuzzy Bitmap License', '{FBM}', NULL);
INSERT INTO public.license VALUES ('759c9684-3616-530f-bd76-0140df091946', 'Fraunhofer FDK AAC Codec Library', '{FDK-AAC}', NULL);
INSERT INTO public.license VALUES ('a2bb9523-6a74-59d3-bbda-0605315049d2', 'Ferguson Twofish License', '{Ferguson-Twofish}', NULL);
INSERT INTO public.license VALUES ('7ca21147-0f00-5b6e-971b-37da5e2da580', 'Frameworx Open License 1.0', '{Frameworx-1.0}', NULL);
INSERT INTO public.license VALUES ('43395af8-5e1d-55b9-a317-730900c4cf05', 'FreeBSD Documentation License', '{FreeBSD-DOC}', NULL);
INSERT INTO public.license VALUES ('012ff7a2-c321-5579-b8a3-b1fe1a4744b5', 'FreeImage Public License v1.0', '{FreeImage}', NULL);
INSERT INTO public.license VALUES ('a8424329-7ddc-5978-938e-717a841270d5', 'FSF All Permissive License', '{FSFAP}', NULL);
INSERT INTO public.license VALUES ('01788494-d71b-556b-b5b4-de9d9799ed4c', 'FSF All Permissive License (without Warranty)', '{FSFAP-no-warranty-disclaimer}', NULL);
INSERT INTO public.license VALUES ('824bc060-8337-566f-b96b-7f9e8fa485c5', 'FSF Unlimited License', '{FSFUL}', NULL);
INSERT INTO public.license VALUES ('cb6351d7-de4d-555c-928e-d305a65cf665', 'FSF Unlimited License (with License Retention)', '{FSFULLR}', NULL);
INSERT INTO public.license VALUES ('d4f9ebce-aea6-5c9a-93d6-455fa57f7491', 'FSF Unlimited License (With License Retention and Warranty Disclaimer)', '{FSFULLRWD}', NULL);
INSERT INTO public.license VALUES ('41e31904-31fd-52a0-9c3a-32fef7a92459', 'Freetype Project License', '{FTL}', NULL);
INSERT INTO public.license VALUES ('ee6e78d7-923a-50e9-85bb-e9de6b51d4d7', 'Furuseth License', '{Furuseth}', NULL);
INSERT INTO public.license VALUES ('03ddf1e5-c671-5478-b26c-b015daecb2a1', 'fwlw License', '{fwlw}', NULL);
INSERT INTO public.license VALUES ('32e8590e-748b-5a68-82a3-2c07bd71271d', 'Gnome GCR Documentation License', '{GCR-docs}', NULL);
INSERT INTO public.license VALUES ('bb22398f-f8c2-5835-b193-7ac36662d033', 'GD License', '{GD}', NULL);
INSERT INTO public.license VALUES ('5ec5284b-14bb-5948-8779-1645503d5872', 'GNU Free Documentation License v1.1', '{GFDL-1.1}', NULL);
INSERT INTO public.license VALUES ('8cc499c9-3221-539e-941a-4584dcc29ed6', 'GNU Free Documentation License v1.1 only - invariants', '{GFDL-1.1-invariants-only}', NULL);
INSERT INTO public.license VALUES ('aa689496-9792-53c3-8f68-5e0cfe5f908a', 'GNU Free Documentation License v1.1 or later - invariants', '{GFDL-1.1-invariants-or-later}', NULL);
INSERT INTO public.license VALUES ('184a9a42-4c69-5395-acbb-34c330e8f1ec', 'GNU Free Documentation License v1.1 only - no invariants', '{GFDL-1.1-no-invariants-only}', NULL);
INSERT INTO public.license VALUES ('846e557f-17ad-59a1-8ae2-b51a405989bf', 'GNU Free Documentation License v1.1 or later - no invariants', '{GFDL-1.1-no-invariants-or-later}', NULL);
INSERT INTO public.license VALUES ('6243162b-3543-52d6-8a3d-01b4c0f55448', 'GNU Free Documentation License v1.1 only', '{GFDL-1.1-only}', NULL);
INSERT INTO public.license VALUES ('2ad41a34-b393-5453-8206-d405ebaabb19', 'GNU Free Documentation License v1.1 or later', '{GFDL-1.1-or-later}', NULL);
INSERT INTO public.license VALUES ('d7c415a1-3c95-5b73-86b9-5c248e653abc', 'GNU Free Documentation License v1.2', '{GFDL-1.2}', NULL);
INSERT INTO public.license VALUES ('e3f3dc62-6faf-5637-9a7f-1308a27b2c53', 'GNU Free Documentation License v1.2 only - invariants', '{GFDL-1.2-invariants-only}', NULL);
INSERT INTO public.license VALUES ('89cb2973-3b9e-55e8-9950-d37423991034', 'GNU Free Documentation License v1.2 or later - invariants', '{GFDL-1.2-invariants-or-later}', NULL);
INSERT INTO public.license VALUES ('2b77b57f-2534-58e7-bfc1-ae05db3cd35c', 'GNU Free Documentation License v1.2 only - no invariants', '{GFDL-1.2-no-invariants-only}', NULL);
INSERT INTO public.license VALUES ('e7ebf75f-ecb9-5c33-aeec-74fc89dca63f', 'GNU Free Documentation License v1.2 or later - no invariants', '{GFDL-1.2-no-invariants-or-later}', NULL);
INSERT INTO public.license VALUES ('72cb8555-d30b-525d-ab5d-0d883d6c124e', 'GNU Free Documentation License v1.2 only', '{GFDL-1.2-only}', NULL);
INSERT INTO public.license VALUES ('372dfb38-158a-5a7a-93c9-317f31328e9a', 'GNU Free Documentation License v1.2 or later', '{GFDL-1.2-or-later}', NULL);
INSERT INTO public.license VALUES ('6e307775-d774-510d-ab82-48dcf4ed959d', 'GNU Free Documentation License v1.3', '{GFDL-1.3}', NULL);
INSERT INTO public.license VALUES ('8e61d0a7-6ba3-5483-9f46-535f6b9e817d', 'GNU Free Documentation License v1.3 only - invariants', '{GFDL-1.3-invariants-only}', NULL);
INSERT INTO public.license VALUES ('5252d22b-da75-59b9-a08a-aa84e42b11a5', 'GNU Free Documentation License v1.3 or later - invariants', '{GFDL-1.3-invariants-or-later}', NULL);
INSERT INTO public.license VALUES ('7e66c019-2125-5b6e-9a3a-5a11d17774f9', 'GNU Free Documentation License v1.3 only - no invariants', '{GFDL-1.3-no-invariants-only}', NULL);
INSERT INTO public.license VALUES ('ef7f50a4-3364-57af-8f97-dfabaff7cb36', 'GNU Free Documentation License v1.3 or later - no invariants', '{GFDL-1.3-no-invariants-or-later}', NULL);
INSERT INTO public.license VALUES ('6a9dfde9-9a51-5a30-8797-76cf820a51a7', 'GNU Free Documentation License v1.3 only', '{GFDL-1.3-only}', NULL);
INSERT INTO public.license VALUES ('795f74df-7b05-56f2-bf1e-9205009b1f7a', 'GNU Free Documentation License v1.3 or later', '{GFDL-1.3-or-later}', NULL);
INSERT INTO public.license VALUES ('0813331e-18a0-5945-bbaa-7c544efb13d4', 'Giftware License', '{Giftware}', NULL);
INSERT INTO public.license VALUES ('2fffff1b-b458-5180-820b-ee3e5a8787ad', 'GL2PS License', '{GL2PS}', NULL);
INSERT INTO public.license VALUES ('8b0972a7-ce87-538f-92c3-c26ab0b7619f', '3dfx Glide License', '{Glide}', NULL);
INSERT INTO public.license VALUES ('0ad2c242-8b86-5beb-91b2-881f6d13ac81', 'Glulxe License', '{Glulxe}', NULL);
INSERT INTO public.license VALUES ('cc6d250d-c8ac-5c3f-96b5-67de1440ece1', 'Good Luck With That Public License', '{GLWTPL}', NULL);
INSERT INTO public.license VALUES ('af3f0570-db9e-56d5-b488-e8f16c4bb7e4', 'gnuplot License', '{gnuplot}', NULL);
INSERT INTO public.license VALUES ('338905e6-664d-5c92-bc81-a81837e1ca32', 'GNU General Public License v1.0 only', '{GPL-1.0}', NULL);
INSERT INTO public.license VALUES ('494ccb38-af0f-58b9-942d-1a64e167c700', 'GNU General Public License v1.0 or later', '{GPL-1.0+}', NULL);
INSERT INTO public.license VALUES ('2f5573fd-b8bb-5ecf-bdb8-75fefafbe7f5', 'GNU General Public License v2.0 only', '{GPL-2.0}', NULL);
INSERT INTO public.license VALUES ('cddb98e9-cc43-58f3-9fa7-5bd2ae0b4b93', 'GNU General Public License v2.0 or later', '{GPL-2.0+}', NULL);
INSERT INTO public.license VALUES ('02a5a241-4f28-5509-af6c-53805849bcd1', 'GNU General Public License v2.0 w/Autoconf exception', '{GPL-2.0-with-autoconf-exception}', NULL);
INSERT INTO public.license VALUES ('51d9e4b9-74ce-5613-93ef-5b4758ac1c02', 'GNU General Public License v2.0 w/Bison exception', '{GPL-2.0-with-bison-exception}', NULL);
INSERT INTO public.license VALUES ('b3b2678f-4ee7-500c-b6ec-0b8bf05c2aa8', 'GNU General Public License v2.0 w/Classpath exception', '{GPL-2.0-with-classpath-exception}', NULL);
INSERT INTO public.license VALUES ('9ef2a43a-ba58-5fc7-8b59-7317ad26d479', 'GNU General Public License v2.0 w/Font exception', '{GPL-2.0-with-font-exception}', NULL);
INSERT INTO public.license VALUES ('e53b90c2-db30-5548-9762-12101693f486', 'GNU General Public License v2.0 w/GCC Runtime Library exception', '{GPL-2.0-with-GCC-exception}', NULL);
INSERT INTO public.license VALUES ('b69e7d45-7842-5acf-b8af-b428fc08ac4f', 'GNU General Public License v3.0 only', '{GPL-3.0}', NULL);
INSERT INTO public.license VALUES ('6bf588b1-e3ba-52d7-9e55-81115b76868c', 'GNU General Public License v3.0 or later', '{GPL-3.0+}', NULL);
INSERT INTO public.license VALUES ('dc8dd3da-eee5-51a3-a456-2f107e324f54', 'GNU General Public License v3.0 w/Autoconf exception', '{GPL-3.0-with-autoconf-exception}', NULL);
INSERT INTO public.license VALUES ('da2b85cf-e7d5-5327-a140-d7ecf09fb530', 'GNU General Public License v3.0 w/GCC Runtime Library exception', '{GPL-3.0-with-GCC-exception}', NULL);
INSERT INTO public.license VALUES ('a5188752-2bac-5fc9-b5cc-6a22fdb4b7a9', 'Graphics Gems License', '{Graphics-Gems}', NULL);
INSERT INTO public.license VALUES ('9f9cb957-a64e-5646-94e1-a0eaa3aba5be', 'gSOAP Public License v1.3b', '{gSOAP-1.3b}', NULL);
INSERT INTO public.license VALUES ('510f4095-b9a8-5ba9-b01e-98f3a914d8ab', 'gtkbook License', '{gtkbook}', NULL);
INSERT INTO public.license VALUES ('4195855e-19ad-567d-839e-dba46c8c88cc', 'Gutmann License', '{Gutmann}', NULL);
INSERT INTO public.license VALUES ('4b03bf25-e8fc-566e-b40b-5cad2b65d2a8', 'Haskell Language Report License', '{HaskellReport}', NULL);
INSERT INTO public.license VALUES ('8ff0bee0-bea8-5906-8ada-b29f49b60d75', 'hdparm License', '{hdparm}', NULL);
INSERT INTO public.license VALUES ('ea3ef3cd-190d-56f2-8c54-72c96827f016', 'HIDAPI License', '{HIDAPI}', NULL);
INSERT INTO public.license VALUES ('aeafaaaa-269c-58ec-b18b-059b9d1af4f6', 'Hippocratic License 2.1', '{Hippocratic-2.1}', NULL);
INSERT INTO public.license VALUES ('baed10fd-a156-5510-9b6d-346f65b0060c', 'Hewlett-Packard 1986 License', '{HP-1986}', NULL);
INSERT INTO public.license VALUES ('7a402340-37e1-5a93-8bff-07a415f4daf0', 'Hewlett-Packard 1989 License', '{HP-1989}', NULL);
INSERT INTO public.license VALUES ('01aad2fd-04c1-5bcc-8764-7634fb1b8c92', 'Historical Permission Notice and Disclaimer', '{HPND}', NULL);
INSERT INTO public.license VALUES ('1672d1eb-538a-5d35-8e3d-0e7a3c5b832f', 'Historical Permission Notice and Disclaimer - DEC variant', '{HPND-DEC}', NULL);
INSERT INTO public.license VALUES ('c3b90e2d-be9c-51ad-8cdd-28e6afa7f3e9', 'Historical Permission Notice and Disclaimer - documentation variant', '{HPND-doc}', NULL);
INSERT INTO public.license VALUES ('a5aaf0c9-056a-58d8-ba89-dfb2c88d8fdb', 'Historical Permission Notice and Disclaimer - documentation sell variant', '{HPND-doc-sell}', NULL);
INSERT INTO public.license VALUES ('6c80eb97-ca4e-51bb-9c40-67fbb5ace67a', 'HPND with US Government export control warning', '{HPND-export-US}', NULL);
INSERT INTO public.license VALUES ('7aa33c84-31f7-5473-adb5-50f9da55fd76', 'HPND with US Government export control warning and acknowledgment', '{HPND-export-US-acknowledgement}', NULL);
INSERT INTO public.license VALUES ('c8243191-2b15-5070-bcef-6a2c042d60f4', 'HPND with US Government export control warning and modification rqmt', '{HPND-export-US-modify}', NULL);
INSERT INTO public.license VALUES ('0dd0daf6-7485-57cf-9e62-70736d090855', 'HPND with US Government export control and 2 disclaimers', '{HPND-export2-US}', NULL);
INSERT INTO public.license VALUES ('b6847705-fdc1-5237-b87d-83634d1039dc', 'Historical Permission Notice and Disclaimer - Fenneberg-Livingston variant', '{HPND-Fenneberg-Livingston}', NULL);
INSERT INTO public.license VALUES ('7509484c-ac58-5baf-a975-bb3a97b8de40', 'Historical Permission Notice and Disclaimer    - INRIA-IMAG variant', '{HPND-INRIA-IMAG}', NULL);
INSERT INTO public.license VALUES ('1275503b-d5bd-58f1-a558-99c26b043f38', 'Historical Permission Notice and Disclaimer - Intel variant', '{HPND-Intel}', NULL);
INSERT INTO public.license VALUES ('3f93d5ee-a301-5483-aa0d-40c16c76b84f', 'Historical Permission Notice and Disclaimer - Kevlin Henney variant', '{HPND-Kevlin-Henney}', NULL);
INSERT INTO public.license VALUES ('e8e32ea6-c23b-5f88-bc81-554d7d52338e', 'Historical Permission Notice and Disclaimer - Markus Kuhn variant', '{HPND-Markus-Kuhn}', NULL);
INSERT INTO public.license VALUES ('53702ea7-0e63-503c-b3c0-413887b81470', 'Historical Permission Notice and Disclaimer - merchantability variant', '{HPND-merchantability-variant}', NULL);
INSERT INTO public.license VALUES ('8124f505-0815-52ef-867e-1e861efa3613', 'Historical Permission Notice and Disclaimer with MIT disclaimer', '{HPND-MIT-disclaimer}', NULL);
INSERT INTO public.license VALUES ('03d105db-2379-531a-9a10-b7caa0700d96', 'Historical Permission Notice and Disclaimer - Netrek variant', '{HPND-Netrek}', NULL);
INSERT INTO public.license VALUES ('23109d83-14ee-5c14-a1d6-01ced2740a1a', 'Historical Permission Notice and Disclaimer - Pbmplus variant', '{HPND-Pbmplus}', NULL);
INSERT INTO public.license VALUES ('05184583-5972-5f40-84f5-3c9ea13df17e', 'Historical Permission Notice and Disclaimer - sell xserver variant with MIT disclaimer', '{HPND-sell-MIT-disclaimer-xserver}', NULL);
INSERT INTO public.license VALUES ('866f9279-65ef-509f-bf34-c712a6af9197', 'Historical Permission Notice and Disclaimer - sell regexpr variant', '{HPND-sell-regexpr}', NULL);
INSERT INTO public.license VALUES ('d203658b-f7f9-569c-a78c-4c8833d0473c', 'Mackerras 3-Clause License', '{Mackerras-3-Clause}', NULL);
INSERT INTO public.license VALUES ('b83faf7a-4585-5a02-ab7c-9d0433f1261d', 'Historical Permission Notice and Disclaimer - sell variant', '{HPND-sell-variant}', NULL);
INSERT INTO public.license VALUES ('83cd6a41-b239-53f0-ad04-716b07603a3e', 'HPND sell variant with MIT disclaimer', '{HPND-sell-variant-MIT-disclaimer}', NULL);
INSERT INTO public.license VALUES ('002428fb-10ac-522e-a428-50923116be4f', 'HPND sell variant with MIT disclaimer - reverse', '{HPND-sell-variant-MIT-disclaimer-rev}', NULL);
INSERT INTO public.license VALUES ('5093e368-dd46-5369-b836-c649482e251a', 'Historical Permission Notice and Disclaimer - University of California variant', '{HPND-UC}', NULL);
INSERT INTO public.license VALUES ('5aa51b87-0419-5e02-809e-7300cecea1d2', 'Historical Permission Notice and Disclaimer - University of California, US export warning', '{HPND-UC-export-US}', NULL);
INSERT INTO public.license VALUES ('528859af-1777-540d-bee9-f13d8a7bd0c5', 'HTML Tidy License', '{HTMLTIDY}', NULL);
INSERT INTO public.license VALUES ('52b1714b-7949-5c18-9c3a-ff715d1eb4e6', 'IBM PowerPC Initialization and Boot Software', '{IBM-pibs}', NULL);
INSERT INTO public.license VALUES ('a5c72d01-b4a6-564e-92e0-783fbf1f7a3c', 'ICU License', '{ICU}', NULL);
INSERT INTO public.license VALUES ('b2df9c5b-3a4f-50ed-9505-404619839c9d', 'IEC    Code Components End-user licence agreement', '{IEC-Code-Components-EULA}', NULL);
INSERT INTO public.license VALUES ('ac44138a-1e46-55d2-96dc-e0e8261454f1', 'Independent JPEG Group License', '{IJG}', NULL);
INSERT INTO public.license VALUES ('8da55b7a-6823-5847-9042-efc75bde11e5', 'Independent JPEG Group License - short', '{IJG-short}', NULL);
INSERT INTO public.license VALUES ('80d58c49-ebcd-5152-a269-bf972d9a201e', 'ImageMagick License', '{ImageMagick}', NULL);
INSERT INTO public.license VALUES ('53512b93-8784-5caa-a6fe-84689ac4c0f6', 'iMatix Standard Function Library Agreement', '{iMatix}', NULL);
INSERT INTO public.license VALUES ('1667c326-b8a3-5497-9d7a-473b0a3cd431', 'Imlib2 License', '{Imlib2}', NULL);
INSERT INTO public.license VALUES ('4193cd37-b396-55d4-9135-93edde6e70bb', 'Info-ZIP License', '{Info-ZIP}', NULL);
INSERT INTO public.license VALUES ('66d7a66f-4caf-5503-83c6-1ceb10d00c9d', 'Inner Net License v2.0', '{Inner-Net-2.0}', NULL);
INSERT INTO public.license VALUES ('658ba5d6-e9a9-5d23-9a7d-23a27c6f1d9b', 'Intel Open Source License', '{Intel}', NULL);
INSERT INTO public.license VALUES ('f73f561d-c95c-5433-97e5-b27403c4cb30', 'Intel ACPI Software License Agreement', '{Intel-ACPI}', NULL);
INSERT INTO public.license VALUES ('87efde03-a869-558a-bf71-8f2f179b9eb3', 'Interbase Public License v1.0', '{Interbase-1.0}', NULL);
INSERT INTO public.license VALUES ('bbeeecae-ff74-5611-b76b-504739a1d04d', 'IPA Font License', '{IPA}', NULL);
INSERT INTO public.license VALUES ('d04162b7-462c-50c6-9a48-06f87a172ba7', 'IBM Public License v1.0', '{IPL-1.0}', NULL);
INSERT INTO public.license VALUES ('11d26b81-93c2-5151-8be4-45b1017c68c3', 'ISC License', '{ISC}', NULL);
INSERT INTO public.license VALUES ('f22535d9-d4b0-52ac-b96d-c918fca56fbd', 'ISC Veillard variant', '{ISC-Veillard}', NULL);
INSERT INTO public.license VALUES ('fe24e99b-0486-5fac-bf86-9322cb5106d4', 'Jam License', '{Jam}', NULL);
INSERT INTO public.license VALUES ('a7ac0288-5d75-5898-ac80-b8a9701092c2', 'JasPer License', '{JasPer-2.0}', NULL);
INSERT INTO public.license VALUES ('fdcd1bd6-1476-57a8-a72a-5d4f27d22341', 'JPL Image Use Policy', '{JPL-image}', NULL);
INSERT INTO public.license VALUES ('0931a854-d9cd-5186-89ca-b848e35a4f8b', 'Japan Network Information Center License', '{JPNIC}', NULL);
INSERT INTO public.license VALUES ('3cd0794f-79e6-5c5d-9cb8-9a7fead99e5f', 'JSON License', '{JSON}', NULL);
INSERT INTO public.license VALUES ('7f78551f-8c9c-5314-bcbe-2a45ab3aa383', 'Kastrup License', '{Kastrup}', NULL);
INSERT INTO public.license VALUES ('32b712b5-312e-5739-a600-31060ba2251b', 'Kazlib License', '{Kazlib}', NULL);
INSERT INTO public.license VALUES ('398b5a2a-3f37-5f40-9e0d-dc40c81ba036', 'Knuth CTAN License', '{Knuth-CTAN}', NULL);
INSERT INTO public.license VALUES ('56e3b1e4-5038-51c2-9122-4fbfdd3b54ae', 'Licence Art Libre 1.2', '{LAL-1.2}', NULL);
INSERT INTO public.license VALUES ('e24c7d08-2fca-5ab5-ae95-33a2a7b5d09d', 'Licence Art Libre 1.3', '{LAL-1.3}', NULL);
INSERT INTO public.license VALUES ('5bd24bd9-1b9e-5aa4-a873-a4313ee7852f', 'Latex2e License', '{Latex2e}', NULL);
INSERT INTO public.license VALUES ('ce1f29e9-ca9c-5b60-8aed-ebf6da1cc152', 'Latex2e with translated notice permission', '{Latex2e-translated-notice}', NULL);
INSERT INTO public.license VALUES ('bc331bdf-a088-5e76-bf7c-50e4fcb47b0d', 'Leptonica License', '{Leptonica}', NULL);
INSERT INTO public.license VALUES ('40f2fc14-9155-59ce-913f-295a82a2b3c3', 'GNU Library General Public License v2 only', '{LGPL-2.0}', NULL);
INSERT INTO public.license VALUES ('a9d63ccf-58fb-5844-a023-1bad5ae0a488', 'GNU Library General Public License v2 or later', '{LGPL-2.0+}', NULL);
INSERT INTO public.license VALUES ('a6d593c8-a43d-599d-8b4a-7a3fab48b381', 'GNU Lesser General Public License v2.1 only', '{LGPL-2.1}', NULL);
INSERT INTO public.license VALUES ('ff6cf2f8-fc25-526b-94f4-addccb37205a', 'GNU Lesser General Public License v2.1 or later', '{LGPL-2.1+}', NULL);
INSERT INTO public.license VALUES ('d98931b8-3fc8-572a-9622-648d3073e771', 'GNU Lesser General Public License v3.0 only', '{LGPL-3.0}', NULL);
INSERT INTO public.license VALUES ('2e095359-1c0d-5cbe-a6f0-35709ae07788', 'GNU Lesser General Public License v3.0 or later', '{LGPL-3.0+}', NULL);
INSERT INTO public.license VALUES ('241a310b-89df-5daf-b120-0bb185637b18', 'Lesser General Public License For Linguistic Resources', '{LGPLLR}', NULL);
INSERT INTO public.license VALUES ('434565a9-8c4b-5a73-98c2-68f68110abfc', 'libpng License', '{Libpng}', NULL);
INSERT INTO public.license VALUES ('105f68d6-a621-5207-a9ef-9af5913c02ae', 'PNG Reference Library version 2', '{libpng-2.0}', NULL);
INSERT INTO public.license VALUES ('99cffc7c-e53f-5776-982c-2ef38f2cfe79', 'libselinux public domain notice', '{libselinux-1.0}', NULL);
INSERT INTO public.license VALUES ('f9e63f93-2d23-50d6-b4af-b4ce99383b11', 'libtiff License', '{libtiff}', NULL);
INSERT INTO public.license VALUES ('566a2894-f987-5475-a07d-f9098ad259ef', 'libutil David Nugent License', '{libutil-David-Nugent}', NULL);
INSERT INTO public.license VALUES ('4b23c203-0356-5fd8-9d71-08578fec6cd4', 'Licence Libre du Québec – Permissive version 1.1', '{LiLiQ-P-1.1}', NULL);
INSERT INTO public.license VALUES ('1f46490f-4040-5ed7-a466-061bb1b44acb', 'Licence Libre du Québec – Réciprocité version 1.1', '{LiLiQ-R-1.1}', NULL);
INSERT INTO public.license VALUES ('46f7c4a4-b3e8-59b6-9c70-68f9fa6658da', 'Licence Libre du Québec – Réciprocité forte version 1.1', '{LiLiQ-Rplus-1.1}', NULL);
INSERT INTO public.license VALUES ('b935aab6-4226-5a91-8d35-9364894da3aa', 'Linux man-pages - 1 paragraph', '{Linux-man-pages-1-para}', NULL);
INSERT INTO public.license VALUES ('acc711a0-a62f-50e7-aafc-ebce966a17de', 'Linux man-pages Copyleft', '{Linux-man-pages-copyleft}', NULL);
INSERT INTO public.license VALUES ('14352ca3-37e0-5d4b-a824-9b078f7e08c9', 'Linux man-pages Copyleft - 2 paragraphs', '{Linux-man-pages-copyleft-2-para}', NULL);
INSERT INTO public.license VALUES ('82b359a7-cab4-5bd7-82bb-34b8dee28409', 'Linux man-pages Copyleft Variant', '{Linux-man-pages-copyleft-var}', NULL);
INSERT INTO public.license VALUES ('086775a4-7b61-5a5a-b065-5c8661d923b0', 'Linux Kernel Variant of OpenIB.org license', '{Linux-OpenIB}', NULL);
INSERT INTO public.license VALUES ('7fd996b5-d420-5e00-9431-84c430e3eb8a', 'Common Lisp LOOP License', '{LOOP}', NULL);
INSERT INTO public.license VALUES ('eeb3f1d2-2201-5b3e-a53f-4286d4073882', 'LPD Documentation License', '{LPD-document}', NULL);
INSERT INTO public.license VALUES ('ecc6bbd1-adb6-5e65-8298-7610400d7658', 'Lucent Public License Version 1.0', '{LPL-1.0}', NULL);
INSERT INTO public.license VALUES ('186313fb-0418-5505-8028-3123085b5b21', 'Lucent Public License v1.02', '{LPL-1.02}', NULL);
INSERT INTO public.license VALUES ('6376d0d0-5bcf-5a15-b248-ddc1bb89007f', 'LaTeX Project Public License v1.0', '{LPPL-1.0}', NULL);
INSERT INTO public.license VALUES ('d7d883da-20f4-516e-83e8-d02e095d5110', 'LaTeX Project Public License v1.1', '{LPPL-1.1}', NULL);
INSERT INTO public.license VALUES ('4241c5c6-4bdf-587e-a21b-9e87a182119a', 'LaTeX Project Public License v1.2', '{LPPL-1.2}', NULL);
INSERT INTO public.license VALUES ('018d57ae-e6ea-5e9e-97d8-03e1d42cedf1', 'LaTeX Project Public License v1.3a', '{LPPL-1.3a}', NULL);
INSERT INTO public.license VALUES ('1ccf24a5-11de-5ccd-aa1f-9e9a5dd0abfb', 'LaTeX Project Public License v1.3c', '{LPPL-1.3c}', NULL);
INSERT INTO public.license VALUES ('604328b0-535f-5ad1-9ec2-1c8489c4d8c6', 'lsof License', '{lsof}', NULL);
INSERT INTO public.license VALUES ('cef88891-6288-5250-a5ff-f1ef58b61a76', 'Lucida Bitmap Fonts License', '{Lucida-Bitmap-Fonts}', NULL);
INSERT INTO public.license VALUES ('6c3aed22-d6c2-5ad0-ae54-f273957be49f', 'LZMA SDK License (versions 9.11 to 9.20)', '{LZMA-SDK-9.11-to-9.20}', NULL);
INSERT INTO public.license VALUES ('95e358e8-cf80-541e-8d15-07c7346d3db0', 'LZMA SDK License (versions 9.22 and beyond)', '{LZMA-SDK-9.22}', NULL);
INSERT INTO public.license VALUES ('f4f0b79b-faef-5acb-a040-dd0c3188546a', 'Mackerras 3-Clause - acknowledgment variant', '{Mackerras-3-Clause-acknowledgment}', NULL);
INSERT INTO public.license VALUES ('716007f7-2b5e-5034-8668-d85ece5dc059', 'magaz License', '{magaz}', NULL);
INSERT INTO public.license VALUES ('7a2c14f2-fb46-510e-a0bc-a4f96bf6da23', 'mailprio License', '{mailprio}', NULL);
INSERT INTO public.license VALUES ('98b32ba6-76e7-5136-8474-9cc4213d5008', 'MakeIndex License', '{MakeIndex}', NULL);
INSERT INTO public.license VALUES ('7c433c44-3765-5498-a031-eb16c52c0491', 'Martin Birgmeier License', '{Martin-Birgmeier}', NULL);
INSERT INTO public.license VALUES ('10ac04b7-dc6c-54cb-a3ca-caf71819cde4', 'McPhee Slideshow License', '{McPhee-slideshow}', NULL);
INSERT INTO public.license VALUES ('9ead6fe2-1a7e-5aa0-b183-36ea728d6465', 'metamail License', '{metamail}', NULL);
INSERT INTO public.license VALUES ('d116f21d-bc96-581d-b10b-8cfaf7d14256', 'Minpack License', '{Minpack}', NULL);
INSERT INTO public.license VALUES ('4d9137c0-0fac-5e09-ac17-e42aca4b87ff', 'The MirOS Licence', '{MirOS}', NULL);
INSERT INTO public.license VALUES ('20a12365-7483-55a4-83dd-124b8805ac91', 'MIT License', '{MIT}', NULL);
INSERT INTO public.license VALUES ('da111430-1cee-5639-a262-cebd850be71a', 'MIT No Attribution', '{MIT-0}', NULL);
INSERT INTO public.license VALUES ('b4f840a1-a14c-55b5-96aa-7a7850052d87', 'Enlightenment License (e16)', '{MIT-advertising}', NULL);
INSERT INTO public.license VALUES ('35371347-27c1-584f-ab7d-30ebc6a92784', 'CMU License', '{MIT-CMU}', NULL);
INSERT INTO public.license VALUES ('dfa1c9dd-73d1-5661-b326-0f7081373eb1', 'enna License', '{MIT-enna}', NULL);
INSERT INTO public.license VALUES ('1785e201-2d5d-5c24-90ea-db17eca6b191', 'feh License', '{MIT-feh}', NULL);
INSERT INTO public.license VALUES ('69224dc1-7e28-5d61-a0b7-76e30f516d67', 'MIT Festival Variant', '{MIT-Festival}', NULL);
INSERT INTO public.license VALUES ('5781f3bd-d77a-5335-9a72-a87a2f7d83dc', 'MIT Khronos - old variant', '{MIT-Khronos-old}', NULL);
INSERT INTO public.license VALUES ('342a6830-6bcb-5db3-bcf5-07ddb2b5c777', 'MIT License Modern Variant', '{MIT-Modern-Variant}', NULL);
INSERT INTO public.license VALUES ('c43d5b6f-d5d5-5e4a-a358-123473850e0d', 'MIT Open Group variant', '{MIT-open-group}', NULL);
INSERT INTO public.license VALUES ('8c6dd3b0-8b39-530c-811b-bbdb46de2325', 'MIT testregex Variant', '{MIT-testregex}', NULL);
INSERT INTO public.license VALUES ('46a5094e-2cdf-5d58-ae51-f4c4e823a7ec', 'MIT Tom Wu Variant', '{MIT-Wu}', NULL);
INSERT INTO public.license VALUES ('0ac2aa8d-1058-5746-ab3e-25df939c9f61', 'MIT +no-false-attribs license', '{MITNFA}', NULL);
INSERT INTO public.license VALUES ('198fe4f2-3d01-5c7e-ae4c-e703d349ef1f', 'MMIXware License', '{MMIXware}', NULL);
INSERT INTO public.license VALUES ('7f1ce444-9b1e-5f36-b049-cae60e0592ec', 'Motosoto License', '{Motosoto}', NULL);
INSERT INTO public.license VALUES ('2fddd0e9-8614-580a-8cbc-fa4b85201fe8', 'MPEG Software Simulation', '{MPEG-SSG}', NULL);
INSERT INTO public.license VALUES ('06f8777f-afe5-5f75-8f5e-d8fb5b0a4352', 'mpi Permissive License', '{mpi-permissive}', NULL);
INSERT INTO public.license VALUES ('77752689-9b02-571e-9d6e-a3a30a2c5ecd', 'mpich2 License', '{mpich2}', NULL);
INSERT INTO public.license VALUES ('086e2204-b80e-530b-a0c3-3cf3a5ce646e', 'Mozilla Public License 1.0', '{MPL-1.0}', NULL);
INSERT INTO public.license VALUES ('53f26fb3-f842-54f0-9560-2beba960adc8', 'Mozilla Public License 1.1', '{MPL-1.1}', NULL);
INSERT INTO public.license VALUES ('74223dd0-5344-5a6f-ae92-4b70fbd42695', 'Mozilla Public License 2.0', '{MPL-2.0}', NULL);
INSERT INTO public.license VALUES ('7e677296-5ec4-50af-b221-e783b7607365', 'Mozilla Public License 2.0 (no copyleft exception)', '{MPL-2.0-no-copyleft-exception}', NULL);
INSERT INTO public.license VALUES ('112cbb03-3b30-5fcb-9db5-7bf28c2fdbb5', 'mplus Font License', '{mplus}', NULL);
INSERT INTO public.license VALUES ('33519aec-020e-5179-884b-6eb692f9403f', 'Microsoft Limited Public License', '{MS-LPL}', NULL);
INSERT INTO public.license VALUES ('3be54d24-7bc6-5726-a928-e74dcb0876cd', 'Microsoft Public License', '{MS-PL}', NULL);
INSERT INTO public.license VALUES ('1ba9b510-b1a5-520b-a224-319742d49d63', 'Microsoft Reciprocal License', '{MS-RL}', NULL);
INSERT INTO public.license VALUES ('5a25eba7-85dc-562c-9681-88bdd129174f', 'Matrix Template Library License', '{MTLL}', NULL);
INSERT INTO public.license VALUES ('bd5b8bea-4af2-523e-abfc-1b0042beeac1', 'Mulan Permissive Software License, Version 1', '{MulanPSL-1.0}', NULL);
INSERT INTO public.license VALUES ('cfbd5ad9-bc9d-525a-b12c-a590d4387e3c', 'Mulan Permissive Software License, Version 2', '{MulanPSL-2.0}', NULL);
INSERT INTO public.license VALUES ('21d5250c-2101-5c20-9f31-d5e5ca292791', 'Multics License', '{Multics}', NULL);
INSERT INTO public.license VALUES ('2127bd0c-621b-5eaa-b258-90b858652ce9', 'Mup License', '{Mup}', NULL);
INSERT INTO public.license VALUES ('612a5495-36aa-5fdf-860a-f0ef5e52bfb2', 'Nara Institute of Science and Technology License (2003)', '{NAIST-2003}', NULL);
INSERT INTO public.license VALUES ('3939dd3c-e720-50d6-a99c-0c95f13c7651', 'NASA Open Source Agreement 1.3', '{NASA-1.3}', NULL);
INSERT INTO public.license VALUES ('1aa59a86-2443-513c-8424-206f003a058f', 'Naumen Public License', '{Naumen}', NULL);
INSERT INTO public.license VALUES ('58bd1cd8-d9ad-532a-b360-a8631c169aa7', 'Net Boolean Public License v1', '{NBPL-1.0}', NULL);
INSERT INTO public.license VALUES ('ebdaefa6-a781-568d-a75e-fab7c791335c', 'NCBI Public Domain Notice', '{NCBI-PD}', NULL);
INSERT INTO public.license VALUES ('54c78287-c581-5e7e-9cf0-2e4446893b9a', 'Non-Commercial Government Licence', '{NCGL-UK-2.0}', NULL);
INSERT INTO public.license VALUES ('26937963-ca1b-5878-88bb-8778a39ca1b3', 'NCL Source Code License', '{NCL}', NULL);
INSERT INTO public.license VALUES ('9eb48c8b-b8cd-5459-a89f-34672c41926f', 'University of Illinois/NCSA Open Source License', '{NCSA}', NULL);
INSERT INTO public.license VALUES ('58b652d6-3cee-5b5e-98a8-efb8f134d729', 'Net-SNMP License', '{Net-SNMP}', NULL);
INSERT INTO public.license VALUES ('18e52d17-f599-5be3-828b-58278acf15a3', 'NetCDF license', '{NetCDF}', NULL);
INSERT INTO public.license VALUES ('90494042-db47-54fa-add0-39de8bcd81f4', 'Newsletr License', '{Newsletr}', NULL);
INSERT INTO public.license VALUES ('4838985b-6cde-5fc6-b632-b01f724ff417', 'Nethack General Public License', '{NGPL}', NULL);
INSERT INTO public.license VALUES ('e4db3972-9324-593e-aec6-d632f5a5a7d3', 'NICTA Public Software License, Version 1.0', '{NICTA-1.0}', NULL);
INSERT INTO public.license VALUES ('f9ce0d8d-8760-5858-871c-3e3efeefaf97', 'NIST Public Domain Notice', '{NIST-PD}', NULL);
INSERT INTO public.license VALUES ('030c97db-2441-517c-bcc5-7a59e2fed316', 'NIST Public Domain Notice with license fallback', '{NIST-PD-fallback}', NULL);
INSERT INTO public.license VALUES ('1167461f-f300-5c84-b660-0b11cb3e55c2', 'NIST Software License', '{NIST-Software}', NULL);
INSERT INTO public.license VALUES ('da8118c5-6731-5d5d-b1d9-5e66530c1860', 'Norwegian Licence for Open Government Data (NLOD) 1.0', '{NLOD-1.0}', NULL);
INSERT INTO public.license VALUES ('eda6e013-3692-5d3a-9a3e-e1f4150dafb5', 'Norwegian Licence for Open Government Data (NLOD) 2.0', '{NLOD-2.0}', NULL);
INSERT INTO public.license VALUES ('5e2fe8d8-ade3-558d-b373-5b863650a79f', 'No Limit Public License', '{NLPL}', NULL);
INSERT INTO public.license VALUES ('56347296-a379-5952-aa07-ae93ff9f35b8', 'Nokia Open Source License', '{Nokia}', NULL);
INSERT INTO public.license VALUES ('9c356536-bdd4-58d5-83d2-c5e0a74d24c0', 'Netizen Open Source License', '{NOSL}', NULL);
INSERT INTO public.license VALUES ('0256aeec-a266-551a-9176-106ac40c5da3', 'Noweb License', '{Noweb}', NULL);
INSERT INTO public.license VALUES ('2fd56ee3-4569-52c2-8ea3-5c4e95fc95c5', 'Netscape Public License v1.0', '{NPL-1.0}', NULL);
INSERT INTO public.license VALUES ('ad8da337-747a-5290-97fe-1534dadfc801', 'Netscape Public License v1.1', '{NPL-1.1}', NULL);
INSERT INTO public.license VALUES ('0c6bac77-df0c-5938-b3be-f8994d4161b9', 'Non-Profit Open Software License 3.0', '{NPOSL-3.0}', NULL);
INSERT INTO public.license VALUES ('d3ecff13-087a-5f19-9bdb-a4d953bc458d', 'NRL License', '{NRL}', NULL);
INSERT INTO public.license VALUES ('e67db654-c6c2-58f3-9602-24603f65b307', 'NTP License', '{NTP}', NULL);
INSERT INTO public.license VALUES ('17ea028a-3789-5680-89a6-e2064c8e7268', 'NTP No Attribution', '{NTP-0}', NULL);
INSERT INTO public.license VALUES ('ae0a0fd9-ae71-59f3-8d87-5edeac5dc126', 'Nunit License', '{Nunit}', NULL);
INSERT INTO public.license VALUES ('1e6737f3-00e4-5582-bc84-7903fbe62075', 'Open Use of Data Agreement v1.0', '{O-UDA-1.0}', NULL);
INSERT INTO public.license VALUES ('9ce8fd44-6bb0-5299-bcb0-4d7467cfeef3', 'OAR License', '{OAR}', NULL);
INSERT INTO public.license VALUES ('db150b4d-f9df-5916-ab62-f5300c97c645', 'Open CASCADE Technology Public License', '{OCCT-PL}', NULL);
INSERT INTO public.license VALUES ('4632027c-18a6-5f0b-9a53-1745a3493ea1', 'OCLC Research Public License 2.0', '{OCLC-2.0}', NULL);
INSERT INTO public.license VALUES ('9170221b-da30-58cf-bdf1-cf6a736fdac6', 'Open Data Commons Open Database License v1.0', '{ODbL-1.0}', NULL);
INSERT INTO public.license VALUES ('9724fea9-3672-52c6-92b7-023b385c3a3e', 'Open Data Commons Attribution License v1.0', '{ODC-By-1.0}', NULL);
INSERT INTO public.license VALUES ('78cf57b5-617e-5131-8545-bfed268209e8', 'OFFIS License', '{OFFIS}', NULL);
INSERT INTO public.license VALUES ('a9d59f6b-e63c-546e-85f9-84ba8e59a40a', 'SIL Open Font License 1.0', '{OFL-1.0}', NULL);
INSERT INTO public.license VALUES ('1c82b243-711a-511f-8577-e91a1d4f3482', 'SIL Open Font License 1.0 with no Reserved Font Name', '{OFL-1.0-no-RFN}', NULL);
INSERT INTO public.license VALUES ('7b8d56cd-643c-5607-bca1-48bea8caf7bf', 'SIL Open Font License 1.0 with Reserved Font Name', '{OFL-1.0-RFN}', NULL);
INSERT INTO public.license VALUES ('2a8a3511-6a7f-55e5-bf81-298e1377e630', 'SIL Open Font License 1.1', '{OFL-1.1}', NULL);
INSERT INTO public.license VALUES ('11312671-77f7-53bf-8329-739ed6b6b8ec', 'SIL Open Font License 1.1 with no Reserved Font Name', '{OFL-1.1-no-RFN}', NULL);
INSERT INTO public.license VALUES ('71910fce-af56-5e54-bb37-703a5e5121a8', 'SIL Open Font License 1.1 with Reserved Font Name', '{OFL-1.1-RFN}', NULL);
INSERT INTO public.license VALUES ('e6ebacd8-61db-52c0-8472-6fd7a0e4ed87', 'OGC Software License, Version 1.0', '{OGC-1.0}', NULL);
INSERT INTO public.license VALUES ('bce8a3ae-f141-5e68-be3d-51173ab3533c', 'Taiwan Open Government Data License, version 1.0', '{OGDL-Taiwan-1.0}', NULL);
INSERT INTO public.license VALUES ('02dd29db-6b22-56d7-bb88-e0586bae3b4c', 'Open Government Licence - Canada', '{OGL-Canada-2.0}', NULL);
INSERT INTO public.license VALUES ('5e0e0507-7230-5ab2-98e2-ec45b6e84454', 'Open Government Licence v1.0', '{OGL-UK-1.0}', NULL);
INSERT INTO public.license VALUES ('8b0ebe60-e36d-51dc-bfe8-b106abb5a427', 'Open Government Licence v2.0', '{OGL-UK-2.0}', NULL);
INSERT INTO public.license VALUES ('1ff864a9-cd17-5778-b656-e2791fd7fa92', 'Open Government Licence v3.0', '{OGL-UK-3.0}', NULL);
INSERT INTO public.license VALUES ('dfe99887-fa60-594c-a477-f58336e88515', 'Open Group Test Suite License', '{OGTSL}', NULL);
INSERT INTO public.license VALUES ('4a63fcc2-24d3-52e0-9943-68c451e22252', 'Open LDAP Public License v1.1', '{OLDAP-1.1}', NULL);
INSERT INTO public.license VALUES ('7c6904bc-2438-5a0b-8c59-e08ce57f03de', 'Open LDAP Public License v1.2', '{OLDAP-1.2}', NULL);
INSERT INTO public.license VALUES ('8710a80c-ba1f-5a2c-a9ea-6a7f67942f43', 'Open LDAP Public License v1.3', '{OLDAP-1.3}', NULL);
INSERT INTO public.license VALUES ('8af04660-8f91-5422-8a71-f6b57cd24686', 'Open LDAP Public License v1.4', '{OLDAP-1.4}', NULL);
INSERT INTO public.license VALUES ('d6d0c684-6a70-5f03-a31f-72eda92a8f2e', 'Open LDAP Public License v2.0 (or possibly 2.0A and 2.0B)', '{OLDAP-2.0}', NULL);
INSERT INTO public.license VALUES ('bd16c9b7-694e-5fd1-b03d-b84cbb908aaf', 'Open LDAP Public License v2.0.1', '{OLDAP-2.0.1}', NULL);
INSERT INTO public.license VALUES ('382ef271-8968-5fb8-8df4-659555a469c2', 'Open LDAP Public License v2.1', '{OLDAP-2.1}', NULL);
INSERT INTO public.license VALUES ('ba197f07-3aed-5085-b633-0024bf1aa2e5', 'Open LDAP Public License v2.2', '{OLDAP-2.2}', NULL);
INSERT INTO public.license VALUES ('ff693d78-eac9-590f-b4c3-a3ace79b8bef', 'Open LDAP Public License v2.2.1', '{OLDAP-2.2.1}', NULL);
INSERT INTO public.license VALUES ('d87f8014-a968-58de-afaa-115bbafee8c7', 'Open LDAP Public License 2.2.2', '{OLDAP-2.2.2}', NULL);
INSERT INTO public.license VALUES ('42ff801c-9936-55a7-b3f0-89d1abb1630c', 'Open LDAP Public License v2.3', '{OLDAP-2.3}', NULL);
INSERT INTO public.license VALUES ('f543ce89-9d53-52c7-8385-e1b58e47530e', 'Open LDAP Public License v2.4', '{OLDAP-2.4}', NULL);
INSERT INTO public.license VALUES ('f13c2e2b-76bd-5c50-91d2-9789ec59cf7a', 'Open LDAP Public License v2.5', '{OLDAP-2.5}', NULL);
INSERT INTO public.license VALUES ('5b49e3a6-bd5f-5de3-b2d7-9d527ecadbc7', 'Open LDAP Public License v2.6', '{OLDAP-2.6}', NULL);
INSERT INTO public.license VALUES ('75d36fca-37e7-5b9a-948e-b541e5004aa5', 'Open LDAP Public License v2.7', '{OLDAP-2.7}', NULL);
INSERT INTO public.license VALUES ('095d06c9-c384-5e62-8745-e4820849982a', 'Open LDAP Public License v2.8', '{OLDAP-2.8}', NULL);
INSERT INTO public.license VALUES ('38b8ed3c-9bd0-5f66-a506-96aa40cf0327', 'Open Logistics Foundation License Version 1.3', '{OLFL-1.3}', NULL);
INSERT INTO public.license VALUES ('61a87a11-a886-5975-8985-3f379e528713', 'Open Market License', '{OML}', NULL);
INSERT INTO public.license VALUES ('391b292a-e512-5dd8-82ef-bf0a940c75b6', 'OpenPBS v2.3 Software License', '{OpenPBS-2.3}', NULL);
INSERT INTO public.license VALUES ('56273237-b202-5fee-86f0-10e623a0a700', 'OpenSSL License', '{OpenSSL}', NULL);
INSERT INTO public.license VALUES ('c1280559-35b4-5446-967d-6902ef12c54e', 'OpenSSL License - standalone', '{OpenSSL-standalone}', NULL);
INSERT INTO public.license VALUES ('99a375e4-9fe4-50ac-a704-3d9004670c7e', 'OpenVision License', '{OpenVision}', NULL);
INSERT INTO public.license VALUES ('24c2b186-d2e8-5b66-ba27-5a15d43de8b6', 'Open Public License v1.0', '{OPL-1.0}', NULL);
INSERT INTO public.license VALUES ('46bb9cc3-4518-534b-9441-e66a18282b83', 'United    Kingdom Open Parliament Licence v3.0', '{OPL-UK-3.0}', NULL);
INSERT INTO public.license VALUES ('31b35391-bb9d-5bd2-a591-53177c059932', 'Open Publication License v1.0', '{OPUBL-1.0}', NULL);
INSERT INTO public.license VALUES ('226fb3eb-858c-53de-88bd-78f1bf3e0754', 'OSET Public License version 2.1', '{OSET-PL-2.1}', NULL);
INSERT INTO public.license VALUES ('093d6dbf-e986-546f-b10f-557ef76fe44e', 'Open Software License 1.0', '{OSL-1.0}', NULL);
INSERT INTO public.license VALUES ('c8639df8-933d-5f02-852c-343db4af5eda', 'Open Software License 1.1', '{OSL-1.1}', NULL);
INSERT INTO public.license VALUES ('af462f02-0e42-509d-b9c0-cb2957202f6b', 'Open Software License 2.0', '{OSL-2.0}', NULL);
INSERT INTO public.license VALUES ('faca82a0-cfd3-51e4-88a8-61632e612da3', 'Open Software License 2.1', '{OSL-2.1}', NULL);
INSERT INTO public.license VALUES ('60174308-a440-5d1c-becc-1fbb25e1b90f', 'Open Software License 3.0', '{OSL-3.0}', NULL);
INSERT INTO public.license VALUES ('d91f5237-83dd-532c-9dae-81e08106dc1a', 'PADL License', '{PADL}', NULL);
INSERT INTO public.license VALUES ('155f6eb1-45e8-59e8-a2e7-362b599c6426', 'The Parity Public License 6.0.0', '{Parity-6.0.0}', NULL);
INSERT INTO public.license VALUES ('2d0ae9d8-b826-5908-9f6f-4d34f5de9634', 'The Parity Public License 7.0.0', '{Parity-7.0.0}', NULL);
INSERT INTO public.license VALUES ('e9b5c525-2654-55fb-9d15-2bec3083de7f', 'Open Data Commons Public Domain Dedication & License 1.0', '{PDDL-1.0}', NULL);
INSERT INTO public.license VALUES ('79e8818e-6bef-587e-8534-fde4e4e023ff', 'PHP License v3.0', '{PHP-3.0}', NULL);
INSERT INTO public.license VALUES ('ab625442-458f-5c7f-be1d-cb2a0d045f85', 'PHP License v3.01', '{PHP-3.01}', NULL);
INSERT INTO public.license VALUES ('0a056a0c-1276-51c0-9aed-5d95376d32ef', 'Pixar License', '{Pixar}', NULL);
INSERT INTO public.license VALUES ('1ee2cda9-daa2-52f4-9035-efcfca1c2882', 'pkgconf License', '{pkgconf}', NULL);
INSERT INTO public.license VALUES ('4054dedb-c9b4-5fe0-a78e-7d2d41ab34da', 'Plexus Classworlds License', '{Plexus}', NULL);
INSERT INTO public.license VALUES ('971ef759-597a-58c8-8c53-ba39dd438a2f', 'pnmstitch License', '{pnmstitch}', NULL);
INSERT INTO public.license VALUES ('8d502226-48ae-5a7b-ac60-372f9881ef40', 'PolyForm Noncommercial License 1.0.0', '{PolyForm-Noncommercial-1.0.0}', NULL);
INSERT INTO public.license VALUES ('46827d60-e110-517e-96ed-9ede798b9770', 'PolyForm Small Business License 1.0.0', '{PolyForm-Small-Business-1.0.0}', NULL);
INSERT INTO public.license VALUES ('13dc5625-e401-5a44-b947-b6c231f1f91c', 'PostgreSQL License', '{PostgreSQL}', NULL);
INSERT INTO public.license VALUES ('778c5e6e-7df1-5b9e-ad3e-700807ef7a24', 'Peer Production License', '{PPL}', NULL);
INSERT INTO public.license VALUES ('238580ad-e86a-5df6-ba92-1957dccd0d33', 'Python Software Foundation License 2.0', '{PSF-2.0}', NULL);
INSERT INTO public.license VALUES ('486dbfff-6dd9-52f7-b767-f483c46f65df', 'psfrag License', '{psfrag}', NULL);
INSERT INTO public.license VALUES ('986d024e-a221-56b4-a14e-e5c000fa1d61', 'psutils License', '{psutils}', NULL);
INSERT INTO public.license VALUES ('5a9194ac-daa7-557d-a721-e44ca496bb0b', 'Python License 2.0', '{Python-2.0}', NULL);
INSERT INTO public.license VALUES ('5791858f-5bd4-53cd-93d8-599dda216042', 'Python License 2.0.1', '{Python-2.0.1}', NULL);
INSERT INTO public.license VALUES ('6a465452-eba4-5297-9dd9-940dee15ab84', 'Python ldap License', '{python-ldap}', NULL);
INSERT INTO public.license VALUES ('eae87745-d550-5b13-a601-3cd0fe72cce8', 'Qhull License', '{Qhull}', NULL);
INSERT INTO public.license VALUES ('cb774e63-d1fc-59ff-8541-50f5bf7837d7', 'Q Public License 1.0', '{QPL-1.0}', NULL);
INSERT INTO public.license VALUES ('f3e6c5c4-9856-5ca4-af82-0d482a747c03', 'Q Public License 1.0 - INRIA 2004 variant', '{QPL-1.0-INRIA-2004}', NULL);
INSERT INTO public.license VALUES ('caae79f5-3a8c-5b00-8f59-78e23a8f1cfe', 'radvd License', '{radvd}', NULL);
INSERT INTO public.license VALUES ('a778b413-c80a-5563-bf15-06be49bff55a', 'Rdisc License', '{Rdisc}', NULL);
INSERT INTO public.license VALUES ('fa156ffc-bdd6-5cef-8bcb-a3d5a0389064', 'Red Hat eCos Public License v1.1', '{RHeCos-1.1}', NULL);
INSERT INTO public.license VALUES ('4d0c64a3-e874-56f7-b49b-0bf0991c1e7a', 'Reciprocal Public License 1.1', '{RPL-1.1}', NULL);
INSERT INTO public.license VALUES ('908615df-2ca8-5eb3-8e63-a4360c93c995', 'Reciprocal Public License 1.5', '{RPL-1.5}', NULL);
INSERT INTO public.license VALUES ('e8829272-72ee-5b5e-899e-805514ed9852', 'RealNetworks Public Source License v1.0', '{RPSL-1.0}', NULL);
INSERT INTO public.license VALUES ('c8a12212-6d9d-5630-87c9-17c3ebb04030', 'RSA Message-Digest License', '{RSA-MD}', NULL);
INSERT INTO public.license VALUES ('dca0aed5-ecbb-5d41-b9a0-ca7283d31379', 'Ricoh Source Code Public License', '{RSCPL}', NULL);
INSERT INTO public.license VALUES ('86a75030-6e52-5424-9f4e-054c7d7140d5', 'Ruby License', '{Ruby}', NULL);
INSERT INTO public.license VALUES ('4456a869-117e-5cca-8dee-fdf8165e8288', 'Ruby pty extension license', '{Ruby-pty}', NULL);
INSERT INTO public.license VALUES ('687979d6-c486-5c13-a729-c301fa21da16', 'Sax Public Domain Notice', '{SAX-PD}', NULL);
INSERT INTO public.license VALUES ('3dbc5727-d0a2-5d27-8271-e91a0658b532', 'Sax Public Domain Notice 2.0', '{SAX-PD-2.0}', NULL);
INSERT INTO public.license VALUES ('c30da003-896e-5087-8bdb-9e4c2c0dbc18', 'Saxpath License', '{Saxpath}', NULL);
INSERT INTO public.license VALUES ('457b155d-6df7-5635-ac2e-b3c79b4f986b', 'SCEA Shared Source License', '{SCEA}', NULL);
INSERT INTO public.license VALUES ('4ef180fd-c293-58d1-a2d6-c006001abaa2', 'Scheme Language Report License', '{SchemeReport}', NULL);
INSERT INTO public.license VALUES ('cb2fa9bc-00d3-542a-8ec4-30c95cf0f383', 'Sendmail License', '{Sendmail}', NULL);
INSERT INTO public.license VALUES ('928bdf90-4c7b-5438-96d7-e37b3b70977f', 'Sendmail License 8.23', '{Sendmail-8.23}', NULL);
INSERT INTO public.license VALUES ('2b6f3c7f-25d4-5bcf-bc1d-d55b8becbff5', 'SGI Free Software License B v1.0', '{SGI-B-1.0}', NULL);
INSERT INTO public.license VALUES ('db1e2af1-2dae-511a-bab6-b9f2984b3d2a', 'SGI Free Software License B v1.1', '{SGI-B-1.1}', NULL);
INSERT INTO public.license VALUES ('83ef00b5-e38a-50f2-8054-def76c5cc9cf', 'SGI Free Software License B v2.0', '{SGI-B-2.0}', NULL);
INSERT INTO public.license VALUES ('6ea0e3c0-9096-5865-93ed-20b69562cb4b', 'SGI OpenGL License', '{SGI-OpenGL}', NULL);
INSERT INTO public.license VALUES ('14f90251-74e3-5801-8b90-4607c96a144c', 'SGP4 Permission Notice', '{SGP4}', NULL);
INSERT INTO public.license VALUES ('2245991d-9dda-5982-96af-ca73dc42610f', 'Solderpad Hardware License v0.5', '{SHL-0.5}', NULL);
INSERT INTO public.license VALUES ('5ef684bb-4844-5da6-a074-44cdf4c61c9b', 'Solderpad Hardware License, Version 0.51', '{SHL-0.51}', NULL);
INSERT INTO public.license VALUES ('695f05cd-31fd-5cf8-9567-3a26ad4cd8e5', 'Simple Public License 2.0', '{SimPL-2.0}', NULL);
INSERT INTO public.license VALUES ('cf6bac8b-f1ae-5ea9-9eb3-4c913b1a3628', 'Sun Industry Standards Source License v1.1', '{SISSL}', NULL);
INSERT INTO public.license VALUES ('f6a6934b-dcf3-5e89-87d3-bc2e4798c259', 'Sun Industry Standards Source License v1.2', '{SISSL-1.2}', NULL);
INSERT INTO public.license VALUES ('c3ab4148-7a5e-5094-a2ca-bfe4fdbc9b69', 'SL License', '{SL}', NULL);
INSERT INTO public.license VALUES ('12e34f28-b18a-5c4f-addc-b62ab434ba3c', 'Sleepycat License', '{Sleepycat}', NULL);
INSERT INTO public.license VALUES ('737da2a3-48c5-5a97-8243-f83bb9a01110', 'Standard ML of New Jersey License', '{SMLNJ}', NULL);
INSERT INTO public.license VALUES ('1588aa6e-dc0c-5825-b967-ddadcf48b221', 'Secure Messaging Protocol Public License', '{SMPPL}', NULL);
INSERT INTO public.license VALUES ('086ea643-0c04-5347-b479-6016628f4acb', 'SNIA Public License 1.1', '{SNIA}', NULL);
INSERT INTO public.license VALUES ('8e470d75-fd10-53b3-a5da-daac3dcc3731', 'snprintf License', '{snprintf}', NULL);
INSERT INTO public.license VALUES ('3e4495ca-a424-5f6f-b7e5-f145438b395f', 'softSurfer License', '{softSurfer}', NULL);
INSERT INTO public.license VALUES ('57a00b15-8987-5f16-8546-f1296eb14784', 'Soundex License', '{Soundex}', NULL);
INSERT INTO public.license VALUES ('794eacbf-3c09-5d05-9646-2acb9ea39e21', 'Spencer License 86', '{Spencer-86}', NULL);
INSERT INTO public.license VALUES ('b23044ff-de00-5f90-9146-9ed768052946', 'Spencer License 94', '{Spencer-94}', NULL);
INSERT INTO public.license VALUES ('1323648c-9eb3-596b-9260-08cbe5f06a00', 'Spencer License 99', '{Spencer-99}', NULL);
INSERT INTO public.license VALUES ('16826de6-1c48-54b1-90dd-f60345d0cb2f', 'Sun Public License v1.0', '{SPL-1.0}', NULL);
INSERT INTO public.license VALUES ('c8d8ec08-1005-5604-8eaa-2655554e5d51', 'ssh-keyscan License', '{ssh-keyscan}', NULL);
INSERT INTO public.license VALUES ('781af1d6-9847-5960-a33f-6028ad44c5e0', 'SSH OpenSSH license', '{SSH-OpenSSH}', NULL);
INSERT INTO public.license VALUES ('70a78492-ac86-5213-85bf-38024442bcd0', 'SSH short notice', '{SSH-short}', NULL);
INSERT INTO public.license VALUES ('3de46875-1155-5e81-8fb6-d99fdb656e98', 'SSLeay License - standalone', '{SSLeay-standalone}', NULL);
INSERT INTO public.license VALUES ('1a16ad60-b616-5014-ab89-d5fd6913bdbf', 'Server Side Public License, v 1', '{SSPL-1.0}', NULL);
INSERT INTO public.license VALUES ('e2082717-f830-5318-a2f0-c74af95fa694', 'SugarCRM Public License v1.1.3', '{SugarCRM-1.1.3}', NULL);
INSERT INTO public.license VALUES ('fc02c180-f529-53ab-91b4-f0f69976bae7', 'Sun PPP License', '{Sun-PPP}', NULL);
INSERT INTO public.license VALUES ('727d4855-4e28-5757-8cb1-72afa5a4e61f', 'Sun PPP License (2000)', '{Sun-PPP-2000}', NULL);
INSERT INTO public.license VALUES ('65042629-0ac7-5268-83c1-708aa3e6c435', 'SunPro License', '{SunPro}', NULL);
INSERT INTO public.license VALUES ('34718fb9-5fbf-5e57-aa9e-150e73bbf183', 'Scheme Widget Library (SWL) Software License Agreement', '{SWL}', NULL);
INSERT INTO public.license VALUES ('1108025e-1a16-5ffa-a04d-609dba05ca18', 'swrule License', '{swrule}', NULL);
INSERT INTO public.license VALUES ('fee57925-15e6-5ad4-b1e9-f6e99753cdc6', 'Symlinks License', '{Symlinks}', NULL);
INSERT INTO public.license VALUES ('f1e5c855-c27d-5c23-b941-77a82c72dc07', 'TAPR Open Hardware License v1.0', '{TAPR-OHL-1.0}', NULL);
INSERT INTO public.license VALUES ('905e65f0-6bac-5a4a-910b-12cbd3313105', 'TCL/TK License', '{TCL}', NULL);
INSERT INTO public.license VALUES ('324ec0bd-7db2-5031-a794-c59d2ae6efec', 'TCP Wrappers License', '{TCP-wrappers}', NULL);
INSERT INTO public.license VALUES ('e695e53d-e929-5a22-acb1-50c965115d2d', 'TermReadKey License', '{TermReadKey}', NULL);
INSERT INTO public.license VALUES ('58b054f6-f7b7-5047-98f3-b1b0217731ac', 'Transitive Grace Period Public Licence 1.0', '{TGPPL-1.0}', NULL);
INSERT INTO public.license VALUES ('30444fb5-6dcf-5e0b-8948-12a9b3cf1620', 'threeparttable License', '{threeparttable}', NULL);
INSERT INTO public.license VALUES ('3d323f82-24a1-5c5f-b5b5-faa055ddfba5', 'TMate Open Source License', '{TMate}', NULL);
INSERT INTO public.license VALUES ('29af735d-fcef-5053-aac3-ae78d7f63072', 'TORQUE v2.5+ Software License v1.1', '{TORQUE-1.1}', NULL);
INSERT INTO public.license VALUES ('5c3b3ba1-ca6c-5cfc-b397-010a672b5fc1', 'Trusster Open Source License', '{TOSL}', NULL);
INSERT INTO public.license VALUES ('d159838f-6243-5ad5-969f-7f196aedd82d', 'Time::ParseDate License', '{TPDL}', NULL);
INSERT INTO public.license VALUES ('05e8db36-9976-5fd4-951b-b7a6dc74678d', 'THOR Public License 1.0', '{TPL-1.0}', NULL);
INSERT INTO public.license VALUES ('81bfb6e5-2959-5a24-aeae-c8a22311f469', 'Text-Tabs+Wrap License', '{TTWL}', NULL);
INSERT INTO public.license VALUES ('13adfd33-cc00-59cf-acbb-955abd7f1c43', 'TTYP0 License', '{TTYP0}', NULL);
INSERT INTO public.license VALUES ('a5caf43d-c894-57bd-a563-e9c439296305', 'Technische Universitaet Berlin License 1.0', '{TU-Berlin-1.0}', NULL);
INSERT INTO public.license VALUES ('7c6d2f9f-d039-5048-b697-33e9221a752d', 'Technische Universitaet Berlin License 2.0', '{TU-Berlin-2.0}', NULL);
INSERT INTO public.license VALUES ('f6bb78d1-f328-569e-a901-7ffaea67dde4', 'UCAR License', '{UCAR}', NULL);
INSERT INTO public.license VALUES ('09ae8f0f-e32f-5673-9bda-57951fd4cf97', 'Upstream Compatibility License v1.0', '{UCL-1.0}', NULL);
INSERT INTO public.license VALUES ('8b90dc4a-084a-5be4-a7b1-89df19bbc82a', 'ulem License', '{ulem}', NULL);
INSERT INTO public.license VALUES ('ab0f7403-57a1-55a1-a217-ab7b1589f596', 'Michigan/Merit Networks License', '{UMich-Merit}', NULL);
INSERT INTO public.license VALUES ('b7b94919-17dc-5759-9ee1-4dccb86a5945', 'Unicode License v3', '{Unicode-3.0}', NULL);
INSERT INTO public.license VALUES ('a447dcd7-9c79-50b0-ba32-8a0e25d498c7', 'Unicode License Agreement - Data Files and Software (2015)', '{Unicode-DFS-2015}', NULL);
INSERT INTO public.license VALUES ('2966cb54-eb8c-5f86-8a4e-6c511f24ca84', 'Unicode License Agreement - Data Files and Software (2016)', '{Unicode-DFS-2016}', NULL);
INSERT INTO public.license VALUES ('5d889658-31d7-5bdf-a00b-776ca3c94359', 'Unicode Terms of Use', '{Unicode-TOU}', NULL);
INSERT INTO public.license VALUES ('c5b5c5eb-c8ff-5613-bf9b-539f8cec111d', 'UnixCrypt License', '{UnixCrypt}', NULL);
INSERT INTO public.license VALUES ('214a28a6-29e9-50e9-91e0-c4e981b89e70', 'The Unlicense', '{Unlicense}', NULL);
INSERT INTO public.license VALUES ('712285a2-a607-5f68-b49b-dd88ab385cfa', 'Universal Permissive License v1.0', '{UPL-1.0}', NULL);
INSERT INTO public.license VALUES ('b38241ac-982a-548c-937f-047eb145d24a', 'Utah Raster Toolkit Run Length Encoded License', '{URT-RLE}', NULL);
INSERT INTO public.license VALUES ('dedf5312-a0f4-50aa-896c-b5909461a484', 'Vim License', '{Vim}', NULL);
INSERT INTO public.license VALUES ('de794ac6-1089-5c7a-9389-3d1026af1ca2', 'VOSTROM Public License for Open Source', '{VOSTROM}', NULL);
INSERT INTO public.license VALUES ('6b0a5523-e602-58db-a7c2-1997600fcaf3', 'Vovida Software License v1.0', '{VSL-1.0}', NULL);
INSERT INTO public.license VALUES ('4aae4a40-1ff3-55b1-a324-b1adcbbe1ed6', 'W3C Software Notice and License (2002-12-31)', '{W3C}', NULL);
INSERT INTO public.license VALUES ('6aaff56e-2bec-5768-b035-2225092b522c', 'W3C Software Notice and License (1998-07-20)', '{W3C-19980720}', NULL);
INSERT INTO public.license VALUES ('445eb9c7-1476-5630-95d4-9af8f3caf526', 'W3C Software Notice and Document License (2015-05-13)', '{W3C-20150513}', NULL);
INSERT INTO public.license VALUES ('ee21fbff-dff2-546e-822a-e219fbbb3126', 'w3m License', '{w3m}', NULL);
INSERT INTO public.license VALUES ('f81adc3c-ca0c-5033-b75b-9d9fca14edcf', 'Sybase Open Watcom Public License 1.0', '{Watcom-1.0}', NULL);
INSERT INTO public.license VALUES ('e2b18b83-45b5-5009-b7ef-f7dcf462ea1a', 'Widget Workshop License', '{Widget-Workshop}', NULL);
INSERT INTO public.license VALUES ('d5baff5a-bf78-5c71-9e19-a7a3ebbf5325', 'Wsuipa License', '{Wsuipa}', NULL);
INSERT INTO public.license VALUES ('c0bb2b28-d6c1-55d9-8f12-dd2c0fdc061e', 'Do What The F*ck You Want To Public License', '{WTFPL}', NULL);
INSERT INTO public.license VALUES ('283f533c-5f85-5de6-be90-30f265d3af45', 'wxWindows Library License', '{wxWindows}', NULL);
INSERT INTO public.license VALUES ('82e923ae-0017-5548-9a23-f7c1409fcfda', 'X11 License', '{X11}', NULL);
INSERT INTO public.license VALUES ('8f14d9b5-de46-5ad4-bcb3-012051eaa3eb', 'X11 License Distribution Modification Variant', '{X11-distribute-modifications-variant}', NULL);
INSERT INTO public.license VALUES ('6c46324e-73fb-5568-a426-996252e7f6a0', 'X11 swapped final paragraphs', '{X11-swapped}', NULL);
INSERT INTO public.license VALUES ('480e6f3d-ba65-596f-86a1-eac866394b4c', 'Xdebug License v 1.03', '{Xdebug-1.03}', NULL);
INSERT INTO public.license VALUES ('67c37ecb-f8ed-57e9-b189-a3b0735057f2', 'Xerox License', '{Xerox}', NULL);
INSERT INTO public.license VALUES ('3c1ab10c-d019-5c49-8cc3-d5dd30761ab4', 'Xfig License', '{Xfig}', NULL);
INSERT INTO public.license VALUES ('68601a33-1158-5a04-9028-fd762ce7a2a1', 'XFree86 License 1.1', '{XFree86-1.1}', NULL);
INSERT INTO public.license VALUES ('d860361c-2730-5712-afdc-ee8a518f2798', 'xinetd License', '{xinetd}', NULL);
INSERT INTO public.license VALUES ('cf24d675-5081-58c3-86ca-c5044f6c3314', 'xkeyboard-config Zinoviev License', '{xkeyboard-config-Zinoviev}', NULL);
INSERT INTO public.license VALUES ('f5520de1-5c73-5274-a2fa-b1eed213afa4', 'xlock License', '{xlock}', NULL);
INSERT INTO public.license VALUES ('3d59bdea-450f-54d5-89f3-0526867cd6a7', 'X.Net License', '{Xnet}', NULL);
INSERT INTO public.license VALUES ('d24f539c-5d45-5ae6-a5f4-180279eaa908', 'XPP License', '{xpp}', NULL);
INSERT INTO public.license VALUES ('fcdd8569-85b8-5863-9a2a-742635ae0e37', 'XSkat License', '{XSkat}', NULL);
INSERT INTO public.license VALUES ('15078d2b-fbd0-5783-8ba1-17bc9f1416be', 'xzoom License', '{xzoom}', NULL);
INSERT INTO public.license VALUES ('7a0a365b-ae9e-5871-a18a-6eddefda7f4e', 'Yahoo! Public License v1.0', '{YPL-1.0}', NULL);
INSERT INTO public.license VALUES ('f802e968-a70f-5175-9c3c-d9d14be1cf78', 'Yahoo! Public License v1.1', '{YPL-1.1}', NULL);
INSERT INTO public.license VALUES ('cb202238-2f77-5d96-922d-226cf404c739', 'Zed License', '{Zed}', NULL);
INSERT INTO public.license VALUES ('65c0e482-b148-52cd-a241-a29312d4c6c6', 'Zeeff License', '{Zeeff}', NULL);
INSERT INTO public.license VALUES ('249c1798-af28-55dc-857a-3b56e531c0ee', 'Zend License v2.0', '{Zend-2.0}', NULL);
INSERT INTO public.license VALUES ('e8ea71c7-6380-56ac-ab6c-fe11dc0baf62', 'Zimbra Public License v1.3', '{Zimbra-1.3}', NULL);
INSERT INTO public.license VALUES ('b4e726e1-73fd-5255-86d3-33d6fc6f7f88', 'Zimbra Public License v1.4', '{Zimbra-1.4}', NULL);
INSERT INTO public.license VALUES ('983e1ddd-1ca6-5bb3-bbc7-6b0f08288c88', 'zlib License', '{Zlib}', NULL);
INSERT INTO public.license VALUES ('2188242f-46f2-5847-8d3d-0dddcf0d9420', 'zlib/libpng License with Acknowledgement', '{zlib-acknowledgement}', NULL);
INSERT INTO public.license VALUES ('949abcda-77a8-522d-9e06-773f8ee1b950', 'Zope Public License 1.1', '{ZPL-1.1}', NULL);
INSERT INTO public.license VALUES ('9a661b38-bc3f-5ebd-9d9c-48f0907b16e4', 'Zope Public License 2.0', '{ZPL-2.0}', NULL);
INSERT INTO public.license VALUES ('f3bd06c4-600b-5707-9514-e6311db99eaa', 'Zope Public License 2.1', '{ZPL-2.1}', NULL);


--
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: package_relates_to_package; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_status; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_version; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_version_range; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: purl_license_assertion; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: purl_status; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: qualified_purl; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: relationship; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.relationship VALUES (0, 'Contains');
INSERT INTO public.relationship VALUES (1, 'Dependency');
INSERT INTO public.relationship VALUES (2, 'DevDependency');
INSERT INTO public.relationship VALUES (3, 'OptionalDependency');
INSERT INTO public.relationship VALUES (4, 'ProvidedDependency');
INSERT INTO public.relationship VALUES (5, 'TestDependency');
INSERT INTO public.relationship VALUES (6, 'RuntimeDependency');
INSERT INTO public.relationship VALUES (7, 'Example');
INSERT INTO public.relationship VALUES (8, 'Generates');
INSERT INTO public.relationship VALUES (9, 'AncestorOf');
INSERT INTO public.relationship VALUES (10, 'Variant');
INSERT INTO public.relationship VALUES (11, 'BuildTool');
INSERT INTO public.relationship VALUES (12, 'DevTool');
INSERT INTO public.relationship VALUES (13, 'Describes');
INSERT INTO public.relationship VALUES (14, 'Package');
INSERT INTO public.relationship VALUES (15, 'Undefined');


--
-- Data for Name: sbom; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sbom_external_node; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sbom_file; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sbom_node; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sbom_node_checksum; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sbom_package; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sbom_package_cpe_ref; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sbom_package_purl_ref; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: source_document; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.status VALUES ('85b912db-fc1b-4e75-8b27-68b68c0ed828', 'affected', 'Affected', 'Vulnerabililty affects');
INSERT INTO public.status VALUES ('619aba21-abba-4220-9e3e-110cf87e5393', 'not_affected', 'Not Affected', 'Vulnerabililty does not affect');
INSERT INTO public.status VALUES ('c0273e43-2b0c-4dae-a3b3-c4f9733fbfa7', 'fixed', 'Fixed', 'Vulnerabililty is fixed');
INSERT INTO public.status VALUES ('23613500-86a4-4cdb-bc92-8c74e18764da', 'under_investigation', 'Under Investigation', 'Vulnerabililty is under investigation');
INSERT INTO public.status VALUES ('2bb0325b-0948-44ea-bab7-46af9fc834eb', 'fixed', 'Fixed', 'Vulnerabililty is fixed');
INSERT INTO public.status VALUES ('858a3f17-d864-4be8-932e-4a634de47b8b', 'recommended', 'Recommended', 'Vulnerabililty is fixed & recommended');


--
-- Data for Name: user_preferences; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: version_range; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: version_scheme; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.version_scheme VALUES ('semver', 'Semantic Versioning', 'Semantic versioning as defined by SemVer 2.0.0 (see https://semver.org/)');
INSERT INTO public.version_scheme VALUES ('ecosystem', 'Ecosystem-specific', 'Ecosystem-specific versioning; otherwise unspecified');
INSERT INTO public.version_scheme VALUES ('git', 'Git commit-hash', 'Git commit-hash-based versioning');
INSERT INTO public.version_scheme VALUES ('deb', 'Debian and Ubuntu', 'https://www.debian.org/doc/debian-policy/ch-relationships.html');
INSERT INTO public.version_scheme VALUES ('rpm', 'RPM distributions', 'https://rpm-software-management.github.io/rpm/manual/dependencies.html');
INSERT INTO public.version_scheme VALUES ('gem', 'Rubygems', 'https://guides.rubygems.org/patterns/#semantic-versioning');
INSERT INTO public.version_scheme VALUES ('npm', 'NPM', 'https://github.com/npm/node-semver#ranges');
INSERT INTO public.version_scheme VALUES ('cpan', 'Perl', 'https://perlmaven.com/how-to-compare-version-numbers-in-perl-and-for-cpan-modules');
INSERT INTO public.version_scheme VALUES ('golang', 'Go modules', 'https://golang.org/ref/mod#versions');
INSERT INTO public.version_scheme VALUES ('maven', 'Apache Maven', 'http://maven.apache.org/enforcer/enforcer-rules/versionRanges.html');
INSERT INTO public.version_scheme VALUES ('nuget', 'NuGet', 'https://docs.microsoft.com/en-us/nuget/concepts/package-versioning#version-ranges');
INSERT INTO public.version_scheme VALUES ('gentoo', 'Gentoo', 'https://wiki.gentoo.org/wiki/Version_specifier');
INSERT INTO public.version_scheme VALUES ('alpine', 'Alpine Linux', 'https://gitlab.alpinelinux.org/alpine/apk-tools/-/blob/master/src/version.c');
INSERT INTO public.version_scheme VALUES ('generic', 'Generic', NULL);
INSERT INTO public.version_scheme VALUES ('python', 'Python', 'https://www.python.org/dev/peps/pep-0440/');
INSERT INTO public.version_scheme VALUES ('packagist', 'PHP Packagist', 'https://packagist.org/about#managing-package-versions');
INSERT INTO public.version_scheme VALUES ('hex', 'Hex Erlang', 'https://hexdocs.pm/elixir/Version.html');
INSERT INTO public.version_scheme VALUES ('swift', 'Swift', 'https://www.swift.org/documentation/package-manager/');
INSERT INTO public.version_scheme VALUES ('pub', 'Pub Dart Flutter', 'https://dart.dev/tools/pub/versioning#semantic-versions');


--
-- Data for Name: versioned_purl; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vulnerability; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vulnerability_description; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: weakness; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: advisory advisory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advisory
    ADD CONSTRAINT advisory_pkey PRIMARY KEY (id);


--
-- Name: advisory advisory_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advisory
    ADD CONSTRAINT advisory_uuid_key UNIQUE (id);


--
-- Name: advisory_vulnerability advisory_vulnerability_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advisory_vulnerability
    ADD CONSTRAINT advisory_vulnerability_pkey PRIMARY KEY (advisory_id, vulnerability_id);


--
-- Name: cpe_license_assertion cpe_license_assertion_idx; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cpe_license_assertion
    ADD CONSTRAINT cpe_license_assertion_idx UNIQUE (sbom_id, license_id, cpe_id);


--
-- Name: cpe_license_assertion cpe_license_assertion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cpe_license_assertion
    ADD CONSTRAINT cpe_license_assertion_pkey PRIMARY KEY (id);


--
-- Name: cpe cpe_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cpe
    ADD CONSTRAINT cpe_pkey PRIMARY KEY (id);


--
-- Name: importer importer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.importer
    ADD CONSTRAINT importer_pkey PRIMARY KEY (name);


--
-- Name: importer_report importer_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.importer_report
    ADD CONSTRAINT importer_report_pkey PRIMARY KEY (id);


--
-- Name: license license_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.license
    ADD CONSTRAINT license_pkey PRIMARY KEY (id);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: base_purl package_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_purl
    ADD CONSTRAINT package_pkey PRIMARY KEY (id);


--
-- Name: package_relates_to_package package_relates_to_package_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_pkey PRIMARY KEY (sbom_id, left_node_id, relationship, right_node_id);


--
-- Name: purl_status package_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_status
    ADD CONSTRAINT package_status_pkey PRIMARY KEY (id);


--
-- Name: base_purl package_type_namespace_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_purl
    ADD CONSTRAINT package_type_namespace_name_key UNIQUE (type, namespace, name);


--
-- Name: versioned_purl package_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versioned_purl
    ADD CONSTRAINT package_version_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_status product_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_status
    ADD CONSTRAINT product_status_pkey PRIMARY KEY (id);


--
-- Name: product_version product_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_version
    ADD CONSTRAINT product_version_pkey PRIMARY KEY (id);


--
-- Name: product_version_range product_version_range_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_version_range
    ADD CONSTRAINT product_version_range_pkey PRIMARY KEY (id);


--
-- Name: purl_license_assertion purl_license_assertion_idx; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_license_assertion
    ADD CONSTRAINT purl_license_assertion_idx UNIQUE (sbom_id, license_id, versioned_purl_id);


--
-- Name: purl_license_assertion purl_license_assertion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_license_assertion
    ADD CONSTRAINT purl_license_assertion_pkey PRIMARY KEY (id);


--
-- Name: qualified_purl qualified_package_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qualified_purl
    ADD CONSTRAINT qualified_package_pkey PRIMARY KEY (id);


--
-- Name: relationship relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT relationship_pkey PRIMARY KEY (id);


--
-- Name: sbom_external_node sbom_external_node_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_external_node
    ADD CONSTRAINT sbom_external_node_pkey PRIMARY KEY (sbom_id, node_id);


--
-- Name: sbom_file sbom_file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_file
    ADD CONSTRAINT sbom_file_pkey PRIMARY KEY (sbom_id, node_id);


--
-- Name: sbom_node_checksum sbom_node_checksum_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_node_checksum
    ADD CONSTRAINT sbom_node_checksum_pkey PRIMARY KEY (sbom_id, node_id, type);


--
-- Name: sbom_node sbom_node_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_node
    ADD CONSTRAINT sbom_node_pkey PRIMARY KEY (sbom_id, node_id);


--
-- Name: sbom_package_cpe_ref sbom_package_cpe_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_package_cpe_ref
    ADD CONSTRAINT sbom_package_cpe_ref_pkey PRIMARY KEY (sbom_id, node_id, cpe_id);


--
-- Name: sbom_package sbom_package_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_package
    ADD CONSTRAINT sbom_package_pkey PRIMARY KEY (sbom_id, node_id);


--
-- Name: sbom_package_purl_ref sbom_package_purl_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_package_purl_ref
    ADD CONSTRAINT sbom_package_purl_ref_pkey PRIMARY KEY (sbom_id, node_id, qualified_purl_id);


--
-- Name: sbom sbom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom
    ADD CONSTRAINT sbom_pkey PRIMARY KEY (sbom_id);


--
-- Name: source_document source_document_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_document
    ADD CONSTRAINT source_document_pkey PRIMARY KEY (id);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (id);


--
-- Name: user_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (user_id, key);


--
-- Name: version_range version_range_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_range
    ADD CONSTRAINT version_range_pkey PRIMARY KEY (id);


--
-- Name: version_scheme version_scheme_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_scheme
    ADD CONSTRAINT version_scheme_pkey PRIMARY KEY (id);


--
-- Name: vulnerability_description vulnerability_description_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vulnerability_description
    ADD CONSTRAINT vulnerability_description_pkey PRIMARY KEY (id);


--
-- Name: vulnerability vulnerability_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vulnerability
    ADD CONSTRAINT vulnerability_pkey PRIMARY KEY (id);


--
-- Name: weakness weakness_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weakness
    ADD CONSTRAINT weakness_pkey PRIMARY KEY (id);


--
-- Name: advisory_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX advisory_id_index ON public.vulnerability_description USING btree (advisory_id);


--
-- Name: advisory_labels_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX advisory_labels_idx ON public.sbom USING gin (labels);


--
-- Name: advisory_vulnerability_advisory_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX advisory_vulnerability_advisory_id_idx ON public.advisory_vulnerability USING btree (advisory_id);


--
-- Name: base_purl_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX base_purl_id_idx ON public.base_purl USING btree (id);


--
-- Name: basepurlnameginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX basepurlnameginidx ON public.base_purl USING gin (name public.gin_trgm_ops);


--
-- Name: basepurlnamespaceginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX basepurlnamespaceginidx ON public.base_purl USING gin (namespace public.gin_trgm_ops);


--
-- Name: basepurltypeginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX basepurltypeginidx ON public.base_purl USING gin (type public.gin_trgm_ops);


--
-- Name: by_id_and_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX by_id_and_version ON public.advisory USING btree (identifier, version);


--
-- Name: by_pid_v; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX by_pid_v ON public.versioned_purl USING btree (base_purl_id, version);


--
-- Name: by_productid_v; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX by_productid_v ON public.product_version USING btree (product_id, version, sbom_id);


--
-- Name: by_pvid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX by_pvid ON public.qualified_purl USING btree (versioned_purl_id);


--
-- Name: cvss3_adv_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cvss3_adv_id_idx ON public.cvss3 USING btree (advisory_id);


--
-- Name: cvss3_adv_id_vuln_id_minor_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cvss3_adv_id_vuln_id_minor_version_idx ON public.cvss3 USING btree (advisory_id, vulnerability_id, minor_version);


--
-- Name: cvss3_vuln_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cvss3_vuln_id_idx ON public.cvss3 USING btree (vulnerability_id);


--
-- Name: cvss4_adv_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cvss4_adv_id_idx ON public.cvss4 USING btree (advisory_id);


--
-- Name: cvss4_vuln_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cvss4_vuln_id_idx ON public.cvss4 USING btree (vulnerability_id);


--
-- Name: name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX name_index ON public.organization USING btree (name);


--
-- Name: not_deprecated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX not_deprecated ON public.advisory USING btree (id) WHERE (deprecated IS NOT TRUE);


--
-- Name: package_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX package_status_idx ON public.purl_status USING btree (base_purl_id, advisory_id, status_id);


--
-- Name: product_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_status_idx ON public.product_status USING btree (context_cpe_id, status_id, package, vulnerability_id);


--
-- Name: purl_status_base_purl_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX purl_status_base_purl_id_idx ON public.purl_status USING btree (base_purl_id);


--
-- Name: purl_status_combo_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX purl_status_combo_idx ON public.purl_status USING btree (base_purl_id, advisory_id, vulnerability_id, status_id, context_cpe_id);


--
-- Name: purl_status_vuln_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX purl_status_vuln_id_idx ON public.purl_status USING btree (vulnerability_id);


--
-- Name: qualified_purl_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualified_purl_id_idx ON public.qualified_purl USING btree (id);


--
-- Name: qualifiedpurlnamejsongistidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlnamejsongistidx ON public.qualified_purl USING gist (((purl ->> 'name'::text)) public.gist_trgm_ops);


--
-- Name: qualifiedpurlnamespacejsongistidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlnamespacejsongistidx ON public.qualified_purl USING gist (((purl ->> 'namespace'::text)) public.gist_trgm_ops);


--
-- Name: qualifiedpurlpurlnamejsonginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlpurlnamejsonginidx ON public.qualified_purl USING gin (((purl ->> 'name'::text)) public.gin_trgm_ops);


--
-- Name: qualifiedpurlpurlnamejsonsortidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlpurlnamejsonsortidx ON public.qualified_purl USING btree (((purl ->> 'name'::text)));


--
-- Name: qualifiedpurlpurlnamespacejsonginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlpurlnamespacejsonginidx ON public.qualified_purl USING gin (((purl ->> 'namespace'::text)) public.gin_trgm_ops);


--
-- Name: qualifiedpurlpurlnamespacejsonsortidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlpurlnamespacejsonsortidx ON public.qualified_purl USING btree (((purl ->> 'namespace'::text)));


--
-- Name: qualifiedpurlpurltyjsonginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlpurltyjsonginidx ON public.qualified_purl USING gin (((purl ->> 'ty'::text)) public.gin_trgm_ops);


--
-- Name: qualifiedpurlpurltyjsonsortidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlpurltyjsonsortidx ON public.qualified_purl USING btree (((purl ->> 'ty'::text)));


--
-- Name: qualifiedpurlpurlversionjsonginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlpurlversionjsonginidx ON public.qualified_purl USING gin (((purl ->> 'version'::text)) public.gin_trgm_ops);


--
-- Name: qualifiedpurlpurlversionjsonsortidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlpurlversionjsonsortidx ON public.qualified_purl USING btree (((purl ->> 'version'::text)));


--
-- Name: qualifiedpurlqualifierarchjsonginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlqualifierarchjsonginidx ON public.qualified_purl USING gin (((qualifiers ->> 'arch'::text)) public.gin_trgm_ops);


--
-- Name: qualifiedpurlqualifierarchjsonsortidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlqualifierarchjsonsortidx ON public.qualified_purl USING btree (((qualifiers ->> 'arch'::text)));


--
-- Name: qualifiedpurlqualifierdistrojsonginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlqualifierdistrojsonginidx ON public.qualified_purl USING gin (((qualifiers ->> 'distro'::text)) public.gin_trgm_ops);


--
-- Name: qualifiedpurlqualifierdistrojsonsortidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlqualifierdistrojsonsortidx ON public.qualified_purl USING btree (((qualifiers ->> 'distro'::text)));


--
-- Name: qualifiedpurlqualifierrepositoryurljsonginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlqualifierrepositoryurljsonginidx ON public.qualified_purl USING gin (((qualifiers ->> 'repository_url'::text)) public.gin_trgm_ops);


--
-- Name: qualifiedpurltypejsongistidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurltypejsongistidx ON public.qualified_purl USING gist (((purl ->> 'ty'::text)) public.gist_trgm_ops);


--
-- Name: qualifiedpurlversionjsongistidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX qualifiedpurlversionjsongistidx ON public.qualified_purl USING gist (((purl ->> 'version'::text)) public.gist_trgm_ops);


--
-- Name: sbom_external_node_external_doc_ref_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_external_node_external_doc_ref_idx ON public.sbom_external_node USING btree (external_type);


--
-- Name: sbom_external_node_external_node_ref_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_external_node_external_node_ref_idx ON public.sbom_external_node USING btree (external_doc_ref);


--
-- Name: sbom_labels_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_labels_idx ON public.sbom USING gin (labels);


--
-- Name: sbom_node_sbom_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_node_sbom_id_idx ON public.sbom_node USING btree (sbom_id);


--
-- Name: sbom_node_sbom_id_node_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_node_sbom_id_node_id_idx ON public.sbom_node USING btree (sbom_id, node_id);


--
-- Name: sbom_package_purl_ref_node_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_package_purl_ref_node_id_idx ON public.sbom_package_purl_ref USING btree (node_id);


--
-- Name: sbom_package_purl_ref_qual_purl_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_package_purl_ref_qual_purl_id_idx ON public.sbom_package_purl_ref USING btree (qualified_purl_id);


--
-- Name: sbom_package_purl_ref_sbom_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_package_purl_ref_sbom_id_idx ON public.sbom_package_purl_ref USING btree (sbom_id);


--
-- Name: sbom_package_sbom_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_package_sbom_id_idx ON public.sbom_package USING btree (sbom_id);


--
-- Name: sbom_package_sbom_id_node_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbom_package_sbom_id_node_id_idx ON public.sbom_package USING btree (sbom_id, node_id);


--
-- Name: sbomnodenameginidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sbomnodenameginidx ON public.sbom_node USING gin (((name)::text) public.gin_trgm_ops);


--
-- Name: sha256_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sha256_index ON public.source_document USING btree (sha256);


--
-- Name: sha384_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sha384_index ON public.source_document USING btree (sha384);


--
-- Name: sha512_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sha512_index ON public.source_document USING btree (sha512);


--
-- Name: versioned_purl_base_purl_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versioned_purl_base_purl_id_idx ON public.versioned_purl USING btree (base_purl_id);


--
-- Name: versioned_purl_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versioned_purl_id_idx ON public.versioned_purl USING btree (id);


--
-- Name: advisory advisory_issuer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advisory
    ADD CONSTRAINT advisory_issuer_id_fkey FOREIGN KEY (issuer_id) REFERENCES public.organization(id);


--
-- Name: advisory advisory_source_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advisory
    ADD CONSTRAINT advisory_source_document_id_fkey FOREIGN KEY (source_document_id) REFERENCES public.source_document(id);


--
-- Name: advisory_vulnerability advisory_vulnerability_advisory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advisory_vulnerability
    ADD CONSTRAINT advisory_vulnerability_advisory_id_fkey FOREIGN KEY (advisory_id) REFERENCES public.advisory(id) ON DELETE CASCADE;


--
-- Name: cpe_license_assertion cpe_license_assertion_cpe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cpe_license_assertion
    ADD CONSTRAINT cpe_license_assertion_cpe_id_fkey FOREIGN KEY (cpe_id) REFERENCES public.cpe(id);


--
-- Name: cpe_license_assertion cpe_license_assertion_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cpe_license_assertion
    ADD CONSTRAINT cpe_license_assertion_license_id_fkey FOREIGN KEY (license_id) REFERENCES public.license(id);


--
-- Name: cpe_license_assertion cpe_license_assertion_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cpe_license_assertion
    ADD CONSTRAINT cpe_license_assertion_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id) ON DELETE CASCADE;


--
-- Name: vulnerability_description fk_adv_vuln; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vulnerability_description
    ADD CONSTRAINT fk_adv_vuln FOREIGN KEY (advisory_id, vulnerability_id) REFERENCES public.advisory_vulnerability(advisory_id, vulnerability_id) ON DELETE CASCADE;


--
-- Name: importer_report importer_report_importer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.importer_report
    ADD CONSTRAINT importer_report_importer_fkey FOREIGN KEY (importer) REFERENCES public.importer(name) ON DELETE CASCADE;


--
-- Name: package_relates_to_package package_relates_to_package_relationship_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_relationship_fkey FOREIGN KEY (relationship) REFERENCES public.relationship(id);


--
-- Name: package_relates_to_package package_relates_to_package_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id) ON DELETE CASCADE;


--
-- Name: package_relates_to_package package_relates_to_package_sbom_id_left_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_sbom_id_left_node_id_fkey FOREIGN KEY (sbom_id, left_node_id) REFERENCES public.sbom_node(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: package_relates_to_package package_relates_to_package_sbom_id_right_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_sbom_id_right_node_id_fkey FOREIGN KEY (sbom_id, right_node_id) REFERENCES public.sbom_node(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: purl_status package_status_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_status
    ADD CONSTRAINT package_status_package_id_fkey FOREIGN KEY (base_purl_id) REFERENCES public.base_purl(id);


--
-- Name: purl_status package_status_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_status
    ADD CONSTRAINT package_status_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.status(id);


--
-- Name: purl_status package_status_version_range_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_status
    ADD CONSTRAINT package_status_version_range_id_fkey FOREIGN KEY (version_range_id) REFERENCES public.version_range(id);


--
-- Name: versioned_purl package_version_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versioned_purl
    ADD CONSTRAINT package_version_package_id_fkey FOREIGN KEY (base_purl_id) REFERENCES public.base_purl(id) ON DELETE CASCADE;


--
-- Name: product_status product_status_advisory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_status
    ADD CONSTRAINT product_status_advisory_id_fkey FOREIGN KEY (advisory_id) REFERENCES public.advisory(id) ON DELETE CASCADE;


--
-- Name: product_status product_status_context_cpe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_status
    ADD CONSTRAINT product_status_context_cpe_id_fkey FOREIGN KEY (context_cpe_id) REFERENCES public.cpe(id);


--
-- Name: product_status product_status_product_version_range_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_status
    ADD CONSTRAINT product_status_product_version_range_id_fkey FOREIGN KEY (product_version_range_id) REFERENCES public.product_version_range(id);


--
-- Name: product_status product_status_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_status
    ADD CONSTRAINT product_status_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.status(id);


--
-- Name: product_status product_status_vulnerability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_status
    ADD CONSTRAINT product_status_vulnerability_id_fkey FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerability(id);


--
-- Name: product product_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.organization(id);


--
-- Name: product_version product_version_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_version
    ADD CONSTRAINT product_version_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: product_version_range product_version_range_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_version_range
    ADD CONSTRAINT product_version_range_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: product_version_range product_version_range_version_range_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_version_range
    ADD CONSTRAINT product_version_range_version_range_id_fkey FOREIGN KEY (version_range_id) REFERENCES public.version_range(id) ON DELETE CASCADE;


--
-- Name: product_version product_version_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_version
    ADD CONSTRAINT product_version_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id) ON DELETE SET NULL;


--
-- Name: purl_license_assertion purl_license_assertion_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_license_assertion
    ADD CONSTRAINT purl_license_assertion_license_id_fkey FOREIGN KEY (license_id) REFERENCES public.license(id);


--
-- Name: purl_license_assertion purl_license_assertion_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_license_assertion
    ADD CONSTRAINT purl_license_assertion_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id) ON DELETE CASCADE;


--
-- Name: purl_license_assertion purl_license_assertion_versioned_purl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_license_assertion
    ADD CONSTRAINT purl_license_assertion_versioned_purl_id_fkey FOREIGN KEY (versioned_purl_id) REFERENCES public.versioned_purl(id);


--
-- Name: purl_status purl_status_advisory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_status
    ADD CONSTRAINT purl_status_advisory_id_fkey FOREIGN KEY (advisory_id) REFERENCES public.advisory(id) ON DELETE CASCADE;


--
-- Name: purl_status purl_status_cpe_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purl_status
    ADD CONSTRAINT purl_status_cpe_fk FOREIGN KEY (context_cpe_id) REFERENCES public.cpe(id);


--
-- Name: qualified_purl qualified_package_package_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qualified_purl
    ADD CONSTRAINT qualified_package_package_version_id_fkey FOREIGN KEY (versioned_purl_id) REFERENCES public.versioned_purl(id) ON DELETE CASCADE;


--
-- Name: sbom_file sbom_file_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_file
    ADD CONSTRAINT sbom_file_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id) ON DELETE CASCADE;


--
-- Name: sbom_node_checksum sbom_node_checksum_sbom_id_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_node_checksum
    ADD CONSTRAINT sbom_node_checksum_sbom_id_node_id_fkey FOREIGN KEY (sbom_id, node_id) REFERENCES public.sbom_node(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: sbom_node sbom_node_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_node
    ADD CONSTRAINT sbom_node_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id) ON DELETE CASCADE;


--
-- Name: sbom_package_cpe_ref sbom_package_cpe_ref_cpe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_package_cpe_ref
    ADD CONSTRAINT sbom_package_cpe_ref_cpe_id_fkey FOREIGN KEY (cpe_id) REFERENCES public.cpe(id);


--
-- Name: sbom_package_cpe_ref sbom_package_cpe_ref_sbom_id_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_package_cpe_ref
    ADD CONSTRAINT sbom_package_cpe_ref_sbom_id_node_id_fkey FOREIGN KEY (sbom_id, node_id) REFERENCES public.sbom_package(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: sbom_package_purl_ref sbom_package_purl_ref_qualified_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_package_purl_ref
    ADD CONSTRAINT sbom_package_purl_ref_qualified_package_id_fkey FOREIGN KEY (qualified_purl_id) REFERENCES public.qualified_purl(id);


--
-- Name: sbom_package_purl_ref sbom_package_purl_ref_sbom_id_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_package_purl_ref
    ADD CONSTRAINT sbom_package_purl_ref_sbom_id_node_id_fkey FOREIGN KEY (sbom_id, node_id) REFERENCES public.sbom_package(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: sbom_package sbom_package_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom_package
    ADD CONSTRAINT sbom_package_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id) ON DELETE CASCADE;


--
-- Name: sbom sbom_source_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sbom
    ADD CONSTRAINT sbom_source_document_id_fkey FOREIGN KEY (source_document_id) REFERENCES public.source_document(id);


--
-- Name: version_range version_range_version_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_range
    ADD CONSTRAINT version_range_version_scheme_id_fkey FOREIGN KEY (version_scheme_id) REFERENCES public.version_scheme(id);


--
-- PostgreSQL database dump complete
--

