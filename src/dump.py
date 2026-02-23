# from queue import Queue
# configurations: Queue[dict[str, float]] = Queue()

# advisor = Advisor(
#         space,
#         # surrogate_type='gp',
#         surrogate_type='auto',
#         task_id='ask_and_tell',
#     )

# MAX_RUNS = 50
#   for i in range(MAX_RUNS):
#       # ask
#       config = advisor.get_suggestion()
#       # evaluate
#       ret = branin(config)
#       # tell
#       observation = Observation(config=config, objectives=ret['objectives'])
#       advisor.update_observation(observation)
#       logger.info('\n===== ITER %d/%d: %s.' % (i+1, MAX_RUNS, observation))
#
#   history = advisor.get_history()
#   print(history)


# print(body)
# assert policy
# policy.update(
#     (
#         request["worker_id"],
#         buckpass.batch_policy.WorkerEvent[request["event"]],
#     ),
# )

# if policy.is_terminated():
#     sys.exit(0)

# global policy
# policy = buckpass.BatchPolicy(
#     args=buckpass.util.OpenBoxTaskId(remote_advisor.task_id),
#     max_runs=buckpass.IntGTZ(100),
#     batch_size=buckpass.IntGTZ(3),
#     submitter=buckpass.SshSubmitter(),
# )

# json.dumps(
#     {
#         "node_ip_address": IPv4Address(
#             address=f"10.0.0.{(os.getenv('SLURMD_NODENAME') or '')[-2:]}"
#         ),
#         "node_port": "",
#         "configurations": arguments.configurations,
#     }
# ),
# class IntGTZ(int):
#     def __new__(cls, value: int) -> Self:
#         assert value > 0
#         return super().__new__(cls, value)
#  if self.path == "/ping":
#     self.send_response(200)
#     self.send_header("Content-type", "application/json")
#     self.end_headers()
#     self.wfile.write(b'{"status":"ok"}')
# else:
#     self.send_error(404)
