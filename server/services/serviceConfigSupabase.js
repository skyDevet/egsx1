import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = import.meta.env?.VITE_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = import.meta.env?.VITE_SUPABASE_ANON_KEY || '';

let _client = null;
function getClient() {
  if (_client) return _client;
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    throw new Error('Supabase not configured. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in .env');
  }
  _client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: { persistSession: true, autoRefreshToken: true },
  });
  return _client;
}

function rowToConfig(row) {
  return {
    id: row.id,
    serviceId: row.service_id,
    name: row.name || { en: '', am: '' },
    description: row.description || { en: '', am: '' },
    initStep: row.init_step ?? 1,
    collectedData: row.collected_data || {},
    steps: row.steps || {},       // apiActions preserved as-is when present, absent when not
    isActive: row.is_active !== false,
    version: row.version ?? 1,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function configToRow(config) {
  return {
    id: config.id,
    service_id: config.serviceId,
    name: config.name,
    description: config.description,
    init_step: config.initStep ?? 1,
    collected_data: config.collectedData || {},
    steps: config.steps || {},    // no forcing — optional
    is_active: config.isActive !== false,
    version: config.version ?? 1,
  };
}

class ServiceConfigSupabase {
  async getAllServiceConfigs() {
    const { data, error } = await getClient().from('service_configs').select('*').order('updated_at', { ascending: false });
    if (error) throw new Error(error.message);
    return (data || []).map(rowToConfig);
  }
  async getServiceConfig(id) {
    const { data, error } = await getClient().from('service_configs').select('*').eq('id', id).maybeSingle();
    if (error) throw new Error(error.message);
    return data ? rowToConfig(data) : null;
  }
  async getServiceConfigsByServiceId(serviceId, includeInactive = false) {
    let q = getClient().from('service_configs').select('*').eq('service_id', serviceId);
    if (!includeInactive) q = q.eq('is_active', true);
    const { data, error } = await q.order('version', { ascending: false });
    if (error) throw new Error(error.message);
    return (data || []).map(rowToConfig);
  }
  async saveServiceConfig(config) {
    const row = configToRow(config);
    const { data, error } = await getClient().from('service_configs').upsert(row, { onConflict: 'id' }).select().single();
    if (error) throw new Error(error.message);
    return rowToConfig(data);
  }
  async deleteServiceConfig(id) {
    const { error } = await getClient().from('service_configs').delete().eq('id', id);
    if (error) throw new Error(error.message);
    return true;
  }
  async deleteAllServiceConfigs() {
    const { error } = await getClient().from('service_configs').delete().neq('id', '__never__');
    if (error) throw new Error(error.message);
    return true;
  }
  subscribe(cb) {
    const ch = getClient().channel('service_configs_changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'service_configs' }, cb)
      .subscribe();
    return () => getClient().removeChannel(ch);
  }
}

let _dbInstance = null;
export async function getServiceConfigDB() {
  if (!_dbInstance) _dbInstance = new ServiceConfigSupabase();
  return _dbInstance;
}

export function getLocalized(obj, lang) {
  if (obj == null) return '';
  if (typeof obj === 'string') return obj;
  const l = lang || (typeof localStorage !== 'undefined' ? (localStorage.getItem('agig_language') === 'am' ? 'am' : 'en') : 'en');
  return obj[l] || obj.en || '';
}

function defaultServiceToRow(svc, version = 1) {
  const serviceId = svc.id || svc.serviceId;
  const now = new Date().toISOString();
  return {
    id: `${serviceId}_v${version}`,
    service_id: serviceId,
    name: svc.name || { en: serviceId, am: serviceId },
    description: svc.description || { en: '', am: '' },
    init_step: svc.initStep ?? 1,
    collected_data: svc.collectedData || {},
    steps: svc.steps || {},       // apiActions preserved only where original had them
    is_active: true,
    version,
    created_at: now,
    updated_at: now,
  };
}

export async function seedDefaultServices(mode = 'if-empty') {
  const client = getClient();
  const { count, error: cErr } = await client.from('service_configs').select('*', { count: 'exact', head: true });
  if (cErr) throw new Error(cErr.message);
  if (mode === 'if-empty' && count && count > 0) return { inserted: 0, skipped: count, total: count, mode };
  if (mode === 'reset') {
    const { error } = await client.from('service_configs').delete().neq('id', '__never__');
    if (error) throw new Error(error.message);
  }
  const mod = await import('./defaultServices.js');
  const defaults = mod.DEFAULT_SERVICES || mod.default || {};
  const rows = Object.values(defaults).map((s) => defaultServiceToRow(s, 1));
  if (!rows.length) return { inserted: 0, skipped: 0, total: 0, mode };
  const { data, error } = await client.from('service_configs').upsert(rows, { onConflict: 'id' }).select();
  if (error) throw new Error(error.message);
  return { inserted: (data || []).length, skipped: 0, total: (data || []).length, mode };
}

export async function ensureDefaultServices() {
  try {
    const r = await seedDefaultServices('if-empty');
    console.log(r.inserted > 0 ? `[seed] inserted ${r.inserted}` : `[seed] skipped (${r.skipped} rows exist)`);
    return r;
  } catch (e) {
    console.warn('[seed] failed:', e.message);
    return { inserted: 0, skipped: 0, total: 0, error: e.message };
  }
}

export const serviceConfigSupabase = { getServiceConfigDB, getLocalized, seedDefaultServices, ensureDefaultServices };
export default serviceConfigSupabase;
