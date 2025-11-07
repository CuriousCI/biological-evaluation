import argparse
import os
from pathlib import Path

import buckpass
from biological_scenarios_generation.model import libsbml, load_biological_model
from buckpass.policy.burst_policy import BurstPolicy
from openbox import space
from openbox.artifact.remote_advisor import RemoteAdvisor

policy: (
    None | BurstPolicy[buckpass.util.SlurmJobId, buckpass.util.OpenBoxTaskId]
) = None


def main() -> None:
    argument_parser: argparse.ArgumentParser = argparse.ArgumentParser()
    _ = argument_parser.add_argument("filename")
    filename: str = str(argument_parser.parse_args().filename)

    path = Path(filename)
    assert path.exists()
    assert path.is_file()

    document: libsbml.SBMLDocument = libsbml.readSBML(filename)
    biological_model = load_biological_model(document)

    _space: space.Space = space.Space()
    _space.add_variables(
        [
            space.Real(kinetic_constant, -20.0, 20.0, 0)
            for kinetic_constant in biological_model.virtual_patient_generator.kinetic_constants
        ]
    )

    remote_advisor: RemoteAdvisor = RemoteAdvisor(
        config_space=_space,
        server_ip="localhost",
        port=8000,
        email="test@test.test",
        password=os.getenv("OPENBOX_PASSWORD"),
        task_name=filename,
        num_objectives=1,
        num_constraints=0,
        sample_strategy="bo",
        surrogate_type="gp",
        acq_type="ei",
        max_runs=100,
    )

    _ = BurstPolicy(
        args=buckpass.openbox_api.TaskId(remote_advisor.task_id),
        batch_size=buckpass.IntGEZ(100),
        submitter=buckpass.Uniroma1Submitter(),
    )


if __name__ == "__main__":
    main()

# socketserver.TCPServer.allow_reuse_address = True
# with socketserver.TCPServer(("", 8080), RequestHandler) as httpd:
#     global policy
#     policy = buckpass.BatchPolicy(
#         args=buckpass.util.OpenBoxTaskId(remote_advisor.task_id),
#         max_runs=buckpass.IntGTZ(100),
#         batch_size=buckpass.IntGTZ(3),
#         submitter=buckpass.SshSubmitter(),
#     )
#     httpd.serve_forever()


# _ = buckpass.BurstPolicy(
#     args=buckpass.openbox_api.TaskId(remote_advisor.task_id),
#     batch_size=buckpass.IntGEZ(100),
#     submitter=buckpass.SshSubmitter(),
# )

# class RequestHandler(http.server.BaseHTTPRequestHandler):
#     def do_POST(self) -> None:
#         content_length = int(self.headers["Content-Length"])
#         body = self.rfile.read(content_length)
#
#         print(body)
#         request: dict[str, str] = json.loads(body.decode("utf-8"))
#         assert policy
#
#         policy.update(
#             (
#                 request["worker_id"],
#                 buckpass.batch_policy.WorkerEvent[request["event"]],
#             )
#         )
#
#         self.send_response(200)
#         self.send_header("Content-type", "application/json")
#         self.end_headers()
#
#         _ = self.wfile.write(b"{}")
#
#         if policy.is_terminated():
#             sys.exit(0)
