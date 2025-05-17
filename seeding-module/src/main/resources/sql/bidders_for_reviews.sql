SELECT bidder_id
FROM tender_bids tb
JOIN tenders t ON tb.tender_id = t.id
WHERE t.publication_id = ?
LIMIT 1