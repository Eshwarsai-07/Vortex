import { createClient } from '@clickhouse/client';

const client = createClient({
    url: process.env.CLICKHOUSE_URL || 'http://localhost:8123',
    user: process.env.CLICKHOUSE_USER || 'default',
    password: process.env.CLICKHOUSE_PASSWORD || 'default',
    database: process.env.CLICKHOUSE_DB || 'logs',
});

export const getLogsByDeploymentId = async (req, res) => {
    const { id } = req.params
    try {
        const query = `
            SELECT log_uuid,deployment_id, log_message, log_level, created_at AS timestamp
            FROM build_logs
            WHERE deployment_id = '${id}'
            ORDER BY created_at ASC

        `;

        const result = await client.query({
            query,
            format: 'JSONEachRow',
        });

        const logs = await result.json();
        return res.status(200).json(logs);
    } catch (error) {
        return res.status(500).json({ message: `Failed to fetch logs: ${error.message}` });
    }
};

