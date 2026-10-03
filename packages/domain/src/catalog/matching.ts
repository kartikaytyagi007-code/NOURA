import type { CatalogFood } from './types.js';

/**
 * Maps a free-text food label (from AI recognition or a user's own typed correction) onto the
 * approved catalog deterministically (blueprint §8 step 5; docs/decisions.md D-025/D-02x). This is
 * intentionally simple string matching, not NLP or embeddings, consistent with D-025's note that
 * dislike/exclusion matching is the same kind of provisional, release-gate-quality heuristic. A label
 * that matches nothing is surfaced honestly as unmatched by the caller — this module never invents a
 * match just to attach a nutrition number.
 */
function normalize(label: string): string {
  return label.trim().toLowerCase().replace(/\s+/g, ' ');
}

/** Exact match (case/space-insensitive) only. Used when a confirmed item names a catalog food. */
export function matchFoodExact(foods: readonly CatalogFood[], label: string): CatalogFood | null {
  const needle = normalize(label);
  return foods.find((f) => normalize(f.name) === needle) ?? null;
}

/**
 * Candidate catalog foods for a recognized label, best first: exact match, then prefix match, then
 * substring match either direction. Returns at most `limit` ids, for the `catalog_candidates` field
 * the contract exposes to the client for manual correction.
 */
export function catalogCandidatesFor(
  foods: readonly CatalogFood[],
  label: string,
  limit = 5,
): string[] {
  const needle = normalize(label);
  if (!needle) return [];
  const scored = foods
    .map((food) => {
      const name = normalize(food.name);
      let score = -1;
      if (name === needle) score = 100;
      else if (name.startsWith(needle) || needle.startsWith(name)) score = 50;
      else if (name.includes(needle) || needle.includes(name)) score = 10;
      return { food, score };
    })
    .filter((s) => s.score >= 0)
    .sort((a, b) => b.score - a.score);
  return scored.slice(0, limit).map((s) => s.food.id);
}

/** The single best catalog match for a label, or null when nothing matches well enough to use. */
export function bestCatalogMatch(foods: readonly CatalogFood[], label: string): CatalogFood | null {
  const exact = matchFoodExact(foods, label);
  if (exact) return exact;
  const candidates = catalogCandidatesFor(foods, label, 1);
  return candidates.length > 0 ? (foods.find((f) => f.id === candidates[0]) ?? null) : null;
}
